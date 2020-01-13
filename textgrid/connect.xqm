xquery version "3.1";

(:~
 : This module provides the functions to transfer data from TextGrid to this
 : instance. It will be called via JavaScript XHR requests from the gui html.
 :)

module namespace tgconnect="https://sade.textgrid.de/ns/connect";

import module namespace config="https://sade.textgrid.de/ns/config" at "../config.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace tgclient="https://sade.textgrid.de/ns/tgclient" at "client.xqm";

declare namespace http="http://expath.org/ns/http-client";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

(: publish function w/o login for inital publish process on autodeployment.
 : during autodeployment no authentication is available, all scripts run
 : externally authenticated as dba.
 : @param $uri – a textgrid uri
 : @param $sid – a valid sessionId for TextGrid
 :  :)
declare function tgconnect:publish( $uri as xs:string, $sid as xs:string ) 
{
    tgconnect:publish
    (
        $uri,
        $sid,
        $target,
        $user,
        $password,
        $project,
        $surface,
        false()
    )
};

(:~ The main function for the publisher.
 : @author Ubbo Veentjer
 : @author Mathias Göbel
 : @param $uri – the TextGrid URI of a single object
 : @param $sid – a valid SessionId able to get the objects
 : @param $target – the path to the collection where the objects should move to
 : @param $user – a username for the db
 : @param $password – the password for the user in the db
 : @param $project – the name of the project where the objects should go to
 : @param $surface – experimental! used in the fontane project to publish parts
 : of a TEI document
 : @param $login – is an authentication required or not? this is used when a db is
 : set up via a post-installation script on autodeploy, where no authentication
 : is required. in those scripts you must set false().
 :)
declare function tgconnect:publish( $uri as xs:string,
                            $sid as xs:string,
                            $target as xs:string,
                            $user as xs:string,
                            $password as xs:string,
                            $project as xs:string,
                            $surface as xs:string,
                            $login as xs:boolean) {

    let $targetPath := $config:app-root || "/" || config:get("project-id")

(: we try to log in at the collection at first, so we can raise an error, if the
 : valid credentials are missing :)
    let $log as xs:boolean :=
        if($login = false())
        then xmldb:login($config:app-root , $user, $password )
        else true()

    return
        if ( $log )
        (: we are logged in, so we can proceed :)
        then
            let $prepare as xs:boolean := local:prepare()
            let $tgcrudUrl as xs:string := config:get("textgrid.tgcrud") => string()
            let $preserveRevisions := config:get("textgrid.preserveRevisions") = "true"

            let $metadataContainer as element( tgmd:MetadataContainerType ) := tgclient:getMeta($uri, $tgcrudUrl, $sid)
            let $tguri := $metadataContainer//tgmd:textgridUri => string()

            let $rdfstoreUrl :=
                    if ($metadataContainer//tgmd:generated/tgmd:availability = "public")
                    then config:get("textgrid.public-triplestore")
                    else config:get("textgrid.nonpublic-triplestore")

(: we are prepared to iterate over the uris we want to publish :)
    return
        for $pubUri in tgclient:getAggregatedUris($tguri, $rdfstoreUrl)
        let $meta := (: we should not download the metadata twice :)
                if($pubUri = $tguri)
                then $metadataContainer
                else tgclient:getMeta($pubUri, $tgcrudUrl, $sid),
            $targetUri := tgclient:remove-prefix($meta//tgmd:textgridUri/text())
                            !  (if($preserveRevisions)
                                then string(.)
                                else substring-before(., '.'))
                            || ".xml",
            $storeMetadata :=
                (: do not store the metadata for images. special threatment for images follows. :)
                if (starts-with($meta//tgmd:format/string(), 'image'))
                then ()
                else xmldb:store($targetPath || "/meta", $targetUri, $meta, "text/xml"),

            $format := string($meta//tgmd:format)
        return
            if(starts-with($format, "image"))
            then
                (   (: we do not store images, but reference the published ones in the file images.xml :)
                    local:image-store( $meta ),
                    "Image: some metadata stored."
                )
            else
            switch ( $format )
                case "text/xml" return
                    let $data :=
                            try     { tgclient:getData($pubUri, $tgcrudUrl, $sid) }
                            catch * { error( QName("https://sade.textgrid.de/ns/error", "PUBLISH03"),
                                        "getData failed with " || $err:code || ": " || $err:description
                                        || "Is your file conform to XML standard?") }
                    let $name := (: JING requires :)
                            if($data/*/namespace-uri() = "http://relaxng.org/ns/structure/1.0")
                            then $targetUri || ".rng"
                            else $targetUri
                    let $store :=
                            try { xmldb:store($targetPath||"/data", $name, $data, "text/xml") }
                            catch * { error( QName("https://sade.textgrid.de/ns/error", "PUBLISH04"),
                                        "storing the data failed with " || $err:code || ": " || $err:description
                                        || "Is your file conform to XML standard? Typical mistakes are empty xml:id attributes.") }

                    let $render := (: this is where you can start with prerendering.
                                      it is recommended to call a function placed
                                      at the bottom or in a separat module. :)
                                  ()
                    let $validate :=
                            (: validation fails on autodeploy :)
                            if( $login = true() ) then () else

                            let $instance := doc( $store )
                            let $grammar := $instance/processing-instruction()
                                                [contains(string(.), "http://relaxng.org/ns/structure/1.0")]
                                                /substring-after(substring-before(., '" type'), "textgrid:")
                              let $relaxNGPath :=  $targetPath || "/data/" || $grammar || ".xml.rng"
                              return
                                  if( ($grammar = "" ) or not($instance//tei:TEI) or not( doc-available( $relaxNGPath ) )) then () else
                                      validation:jaxv-report($instance, doc($relaxNGPath))
(:                                    $grammar:)

                    return ($targetUri, $validate)

                case "text/xml+xslt" return
                    let $data := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                    let $store := xmldb:store($targetPath || "/data", $targetUri, $data, "text/xml")
                    return $targetUri

                case "text/xsd+xml" return
                    let $data := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                    let $store := xmldb:store($targetPath || "/data", replace($targetUri, "xml", "xsd.xml"), $data, "text/xml")
                    return $targetUri

                case "text/linkeditorlinkedfile" return
                    let $data :=
                            try     { tgclient:getData($pubUri, $tgcrudUrl, $sid) }
                            catch * { error( QName("https://sade.textgrid.de/ns/error", "PUBLISH05"),
                                        "get data failed with " || $err:code || ": " || $err:description
                                        )}
                    let $store :=
                            try { xmldb:store($targetPath || '/tile', $targetUri, $data) }
                            catch * { error( QName("https://sade.textgrid.de/ns/error", "PUBLISH06"),
                                        "get data failed with " || $err:code || ": " || $err:description
                                        ) }
                    return $targetUri

                case "text/tg.inputform+rdf+xml" return
                    let $data := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                    let $store := xmldb:store($targetPath||"/rdf", $targetUri, $data, "text/xml")
                    return $targetUri

                case "text/tg.aggregation+xml" return
                        let $data := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                        let $store := xmldb:store($targetPath||"/agg", $targetUri, $data, "text/xml")
                        return $targetUri

                case "text/tg.collection+tg.aggregation+xml" return
                        let $data := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                        let $store := xmldb:store($targetPath||"/agg", $targetUri, $data, "text/xml")
                        return $targetUri

                case "text/tg.edition+tg.aggregation+xml" return
                        let $data := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                        let $store := xmldb:store($targetPath||"/agg", $targetUri, $data, "text/xml")
                        return $targetUri

                case "text/plain" return
                        let $text := tgclient:getData($pubUri, $tgcrudUrl, $sid)
                        let $base64 := xs:base64Binary(util:base64-encode($text))
                        let $path := system:get-exist-home() || util:system-property("file.separator")
                        let $name := replace($targetUri, "xml", "txt")
                        let $title := string($meta//tgmd:title)
                        let $store :=
                            if( $title = ("synonyms.txt", "charmap.txt") )
                            then
                                let $do :=  try     { file:serialize-binary( $base64, $path || $title  ) }
                                            catch * { error(
                                                        QName("https://sade.textgrid.de/ns/error", "PUBLISH07"),
                                                        "storing lucene configuration failed with " || $err:code || ": " || $err:description)
                                                    },
                                    $reindex := xmldb:reindex( $targetPath || "/data" )
                                return
                                    $path || $title
                            else
                                xmldb:store($targetPath || "/data", $name, $text, "text/plain")
                        return $name
                default return
                        error(
                            QName("https://sade.textgrid.de/ns/error", "PUBLISH08"),
                            "The publisher does not know how to handle " || string($meta//tgmd:format) || "."
                            )

else
    error(
        QName("https://sade.textgrid.de/ns/error", "PUBLISH02"),
        "error authenticating for " || $user || " on " || $targetPath
        )
};

(:~
 : checks and prepares all collections
 : @author Mathias Göbel
 : @param $path – the path to the data collection
 :)
declare function local:prepare() as xs:boolean {
let $project-id := config:get("project-id")
return
    if( xmldb:collection-available(xs:anyURI($config:app-root || "/" || $project-id)) ) then true()
    else
        let $do :=
        (xmldb:create-collection($config:app-root, $project-id),
         xmldb:create-collection($config:app-root || "/" || $project-id, "data"),
         xmldb:create-collection($config:app-root || "/" || $project-id, "meta"),
         xmldb:create-collection($config:app-root || "/" || $project-id, "agg"),
         xmldb:create-collection($config:app-root || "/" || $project-id, "tile"),
         xmldb:create-collection($config:app-root || "/" || $project-id, "rdf")
        )
        return true()
};


declare function local:image-store($meta) {
    if(doc-available( $config:data-root || "/images.xml" ))
    then
        update insert
            <image
                uri="{string($meta//tgmd:textgridUri)}"
                title="{string($meta//tgmd:title)}"
                format="{string($meta//tgmd:format)}"
            />
        into doc($config:data-root || "/images.xml")/images
    else
        (
            xmldb:store($config:data-root, "images.xml", <images/>),
            local:image-store($meta)
        )
};

declare function tgconnect:store($targetPath, $type, $targetUri, $data){
(
    if( doc-available($targetPath || '/' || $type || '/' || $targetUri) )
    then xmldb:remove($targetPath || '/' || $type, $targetUri)
    else (),
    xmldb:store($targetPath || '/' || $type, $targetUri, $data, "text/xml")
)
};

(:~ prerendering of large files or heavy transformation to be done on publish.
 : used extensivly by the project on Fontane`s Notebooks.
 : @param $data – the document to transform
 : @param $path – the path where to finde the file
 : @param $uri – the TextGrid URI of the document
 :  :)
declare function tgconnect:prerender($data, $path, $uri){
    ()
};

declare function local:progress($uri as xs:string, $page as xs:string, $value as xs:float){
(:
 : this was meant to create a progressbar in the frontend. was made with many many many ajax calls,
 : in the era of websockets, we have to rethink about this feature.
 :)
    ()
};

declare function local:copy-filter-elements($element, $element-name as xs:string*) as item() {
(: untyped variables only: PI is not an element, element is not PI, ... :)
if($element instance of processing-instruction()) then
    let $wrapper :=  <wrap>{ $element }</wrap>
    return
        $wrapper/processing-instruction()
else
   element {node-name($element) }
         { $element/@*,
           for $child in $element/node()[not(name(.)=$element-name)]
              return if ($child instance of element())
                then local:copy-filter-elements($child,$element-name)
                else $child
       }
};
