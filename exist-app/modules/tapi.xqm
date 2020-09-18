xquery version "3.1";

(:~
 : This module provides the TextAPI for Ahiqar. For an extensive explanation of
 : the whole Ahiqar specific implementation of the generic TextAPI see the link
 : to the API docs.
 :
 : @author Mathias Göbel
 : @author Michelle Weidling
 : @since 0.0.0
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/
 : :)

module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi";

declare namespace expkg="http://expath.org/ns/pkg";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace coll="http://ahikar.sub.uni-goettingen.de/ns/collate" at "collate.xqm";
import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace functx="http://www.functx.com";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";

declare variable $tapi:server := if(requestr:hostname() = "existdb") then $commons:expath-pkg/*/@name => replace("/$", "") else "http://localhost:8094/exist/restxq";

(:~
 : Shows information about the currently installed application.
 :
 : @return The content of the app's expath-pkg.xml and repo.xml as JSON
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/info")
    %output:method("json")
function tapi:info-rest()
as item()+ {
    $commons:responseHeader200,
    tapi:info()
};

(:~
 : Retrieves info about the Ahiqar app.
 :
 : @return element(descriptors)
 :)
declare function tapi:info()
as element(descriptors) {
    <descriptors>
        <request>
            <scheme>{ requestr:scheme() }</scheme>
            <hostname>{ requestr:hostname() }</hostname>
            <uri>{ requestr:uri() }</uri>
        </request>
        {
            tapi:remove-whitespaces(doc($commons:appHome || "/expath-pkg.xml")),
            tapi:remove-whitespaces(doc($commons:appHome || "/repo.xml"))
        }
    </descriptors>
};

(:~ 
 : Removes all line breaks and surplus white spaces from XML files.
 : This way we avoid producing a littered JSON with fields that only contain
 : white space text.
 : 
 : @author Michelle Weidling
 : @param $doc The XML document to be transformed
 : @return $doc but without indentation
 :)
declare function tapi:remove-whitespaces($doc as document-node()) as document-node() {
    $doc => serialize() => replace("[\s]{2,}", "") => replace("[\n]", "") => parse-xml()
};


(:~
 : Returns information about a given document as specified at
 : https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest.
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest
 : @param $collection The unprefixed TextGrid URI of a collection, e.g. '3r84g'
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r679'
 : @return An object element containing all necessary information about a manifest object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection}/{$document}/manifest.json")
    %output:method("json")
function tapi:manifest-rest($collection as xs:string, $document as xs:string)
as item()+ {
    $commons:responseHeader200,
    tapi:manifest($collection, $document, $tapi:server)
};


(:~
 : Returns information about an edition object (i.e. an aggregation) which holds
 : an XML document as well as the facsimiles.
 : 
 : In contrast to the generic TextAPI specs on manifest objects we do not provide an
 : ID at this point. One reason is the TextGrid metadata model, the other is FRBR.
 : 
 : @param $collection The URI of the document's parent collection, e.g. '3r9ps'
 : @param $document The URI of an edition object, e.g. '3r177'
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable and defaults to $tapi:server.
 : @return An object element containing all necessary information about a manifest object
 :)
declare function tapi:manifest($collection as xs:string, $document as xs:string,
$server as xs:string)
as element(object) {
    let $aggNode := doc($commons:agg || $document || ".xml")
    let $metaNode := doc($commons:tg-collection || "/meta/" || $document || ".xml")
    let $documentUri := $aggNode//ore:aggregates[1]/@rdf:resource => substring-after(":")
    let $documentNode := doc($commons:data || $documentUri || ".xml")
    let $sequence :=
        for $page in $documentNode//tei:pb[@facs]/string(@n)
        let $uri := "/api/textapi/ahikar/" || $collection || "/" || $document || "-" ||  $page || "/latest/item.json"
        return
            <sequence>
                <id>{$server}{$uri}</id>
                <type>item</type>
            </sequence>
    let $id := $server || "/api/textapi/ahikar/" || $collection || "/" || $document || "/manifest.json"
            
    return
    <object>
        <textapi>{$commons:version}</textapi>
        <id>{$id}</id>
        <label>{string($metaNode//tgmd:title)}</label>
        {
            tapi:make-editors($documentNode),
            tapi:make-date($documentNode),
            tapi:make-origin($documentNode),
            tapi:make-location($documentNode)
        }
        <license>CC0-1.0</license>
        <annotationCollection>{$server}/api/textapi/ahikar/{$collection}/{$document}/annotationCollection.json</annotationCollection>
        {$sequence}
    </object>
};


(:~ 
 : Creates the necessary information about editors.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#actor-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-editor element with all information necessary for an Actor Object.
 :)
declare function tapi:make-editors($documentNode as document-node()) as element(x-editor)* {
    let $role := "editor"
    let $has-editor := exists($documentNode//tei:titleStmt//tei:editor)
    return
        if ($has-editor) then
            for $editor in $documentNode//tei:titleStmt//tei:editor
            return
                <x-editor>
                    <role>{$role}</role>
                    <name>{$editor/string()}</name>
                </x-editor>
        else
            <x-editor>
                <name>none</name>
            </x-editor>
};

(:~
 : Creates the necessary information about a manuscript's origin from the TEI
 : header.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#manifest-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-origin element containing a descriptive string
 :)
declare function tapi:make-origin($documentNode as document-node()) as 
element(x-origin)? {
    let $country := $documentNode//tei:history//tei:country
    let $place := $documentNode//tei:history//tei:placeName
    let $string :=
        if ($country and $place) then
            $place/string() || ", " || $country/string()
        else if ($country) then
            $country/string()
        else if($place) then
            $place/string()
        else
            "unknown"
    return
        <x-origin>{$string}</x-origin>
};


(:~
 : Creates the necessary information about a manuscript's creation date from the
 : TEI header.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#manifest-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-date element containing a descriptive string
 :)
declare function tapi:make-date($documentNode as document-node()) as
element(x-date)? {
    let $date := $documentNode//tei:history//tei:date
    let $string :=
        if ($date) then
            $date/string()
        else
            "unknown"
    return
        <x-date>{$string}</x-date>
};


(:~
 : Creates the necessary information about a manuscript's current location from
 : the TEI header.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#manifest-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-location element containing a descriptive string
 :)
declare function tapi:make-location($documentNode as document-node()) as
element(x-location) {
    let $institution := $documentNode//tei:msIdentifier//tei:institution
    let $country := $documentNode//tei:msIdentifier//tei:country
    let $string :=
        if ($country and $institution) then
            $institution || ", " || $country
        else if ($country) then
            $country/string()
        else if($institution) then
            $institution/string()
        else
            "unknown"
    return
        <x-location>{$string}</x-location>

};


(:~ 
 : Returns the API endpoints of all pages of the manuscript.
 : Since we also have transliterations, only "original" pages (i.e. the ones
 : with a facsimile) are considered for the endpoints.
 : 
 : @param $documentNode The opened TEI file of the current manifest
 : @retun A sequence of sequence elements
 :)
declare function tapi:make-sequence($documentNode as document-node()) as
element(sequence)+ {
    for $page in $documentNode//tei:pb[@facs]/string(@n)
        let $uri := "/api/textapi/ahikar/" || $collection || "/" || $document || "-" ||  $page || "/latest/item.json"
        return
            <sequence>
                <id>{$server}{$uri}</id>
                <type>item</type>
            </sequence>
};

(:~
 : Returns information about a given page in a document. This is mainly compliant
 : with the SUB TextAPI, but has the following additions:
 :  * the division number, 'n', is mandatory
 :  * 'image' is mandatory since every page has a facsimile
 : 
 : The parameter $collection is actually not necessary but introduced to keep
 : the structure of the API clear.
 :
 : Sample call to API: /api/textapi/ahikar/3r17c/3r1pq-147a/latest/item.json
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#item
 : @param $collection The unprefixed TextGrid URI of a collection, e.g. '3r17c'
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r1pq'
 : @param $page A page number as encoded in a tei:pb/@n, e.g. '147a'
 : @return Information about a page
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection}/{$document}-{$page}/latest/item.json")
    %output:method("json")
function tapi:item-rest($collection as xs:string, $document as xs:string,
$page as xs:string) as item()+ {
    $commons:responseHeader200,
    tapi:item($collection, $document, $page, $tapi:server)
};


(:~
 : Returns information about a given page.
 :
 : @param $document The unprefixed TextGrid URI of a collection, e.g. '3r9ps'
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r1pq'
 : @param $page A page number as encoded in a tei:pb/@n, e.g. '147a'
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable and defaults to $tapi:server.
 : @return An object element containing all necessary information about an item
 :)
declare function tapi:item($collection as xs:string, $document as xs:string,
$page as xs:string, $server as xs:string) 
as element(object) {
    let $aggNode := doc($commons:agg || $document || ".xml")
    let $teiUri :=
        if($aggNode)
            then $aggNode//ore:aggregates[1]/@rdf:resource => substring-after(":")
        else $document
    let $image := doc($commons:data || $teiUri || ".xml")//tei:pb[@n = $page]/@facs => substring-after("textgrid:")
    
    let $xml := doc($commons:data || $teiUri || ".xml")
    let $title := $xml//tei:title[@type = "main"]/string()
    let $iso-languages := 
        $xml//tei:language[@xml:base = "https://iso639-3.sil.org/code/"]/@ident/string()
    let $alt-languages :=
        $xml//tei:language[not(@xml:base = "https://iso639-3.sil.org/code/")]/@ident/string()
    let $langString :=
        for $lang in $xml//tei:language/text()
        order by $lang
        return $lang
    let $langString := string-join($langString, ", ")
    
    return
    <object>
        <textapi>{$commons:version}</textapi>
        <title>{$title}</title>
        <type>page</type>
        <n>{$page}</n>
        <content>{$server}/api/content/{$teiUri}-{$page}.html</content>
        <content-type>application/xhtml+xml</content-type>
        {
            for $lang in $iso-languages return
                element lang {$lang}
        }
        {
            for $lang in $alt-languages return
                element langAlt {$lang}
        }
        <x-langString>{$langString}</x-langString>
        <image>
            <id>{$server}/api/images/{$image}</id>
        </image>
        <annotationCollection>{$server}/api/textapi/ahikar/{$collection}/{$document}-{$page}/annotationCollection.json</annotationCollection>
    </object>
};


(:~
 : Returns an HTML rendering of a given page.
 : 
 : Since we only return a fragment of an HTML page which can be integrated in a
 : viewer or the like, we chose XML as output method in order to avoid setting
 : a DOCTYPE on a fragment.
 :
 : Sample call to API: /content/3rbmb-1a.html
 :
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3rbmb'
 : @param $page The page to be rendered. This has to be the string value of a tei:pb/@n in the given document, e.g. '1a'
 : @return A response header as well as the rendered HTML page
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/{$document}-{$page}.html")
    %output:method("xml")
    %output:indent("no")
function tapi:content-rest($document as xs:string, $page as xs:string)
as item()+ {
    $commons:responseHeader200,
    tapi:content($document, $page)
};


(:~
 : Initiates the HTML serialization of a given page.
 :
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3rbmb'
 : @param $page The page to be rendered. This has to be the string value of a tei:pb/@n in the given document, e.g. '1a'
 : @return A div wrapper containing the rendered page
 :)
declare function tapi:content($document as xs:string, $page as xs:string)
as element(div) {
    let $documentPath := $commons:data || $document || ".xml"
    let $TEI :=
        if($page)
        then
            let $node := doc($documentPath)/* => tapi:add-IDs(),
                $start-node := $node//tei:pb[@n = $page and @facs],
                $end-node :=
                    let $followingPb := $node//tei:pb[@n = $page and @facs]/following::tei:pb[1][@facs]
                    return
                        if($followingPb)
                        then $followingPb
                        else $node//tei:pb[@n = $page and @facs]/following::tei:ab[last()],
                $wrap-in-first-common-ancestor-only := false(),
                $include-start-and-end-nodes := false(),
                $empty-ancestor-elements-to-include := ("")
            return
                fragment:get-fragment-from-doc(
                    $node,
                    $start-node,
                    $end-node,
                    $wrap-in-first-common-ancestor-only,
                    $include-start-and-end-nodes,
                    $empty-ancestor-elements-to-include)
        else doc($documentPath)/*
    let $stylesheet := doc("/db/apps/sade_assets/TEI-Stylesheets/html5/html5.xsl")
    let $transform := transform:transform($TEI, $stylesheet, ())/xhtml:body//xhtml:div[@class = "tei_body"]
    return
        <div>
            {$transform}
        </div>
};


(:~
 : Returns an image belonging to a given URI. This function doesn't work locally
 : unless you have all necessary login information filled in at ahikar.env.
 : 
 : Since the images of the Ahikar project aren't publicly available, this
 : function cannot be tested by unit tests.
 :
 : @param $uri The unprefixed TextGrid URI of an image, e.g. '3r1pr'
 : @return The image as binary
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/images/{$uri}")
    %rest:produces("image/jpeg")
    %output:method("binary")
function tapi:images-rest($uri as xs:string)
as item()+ {
    $commons:responseHeader200,
    hc:send-request(
        <hc:request method="GET"
        href="https://textgridlab.org/1.0/digilib/rest/IIIF/textgrid:{$uri};sid={environment-variable('TEXTGRID.SESSION')}/full/,2000/0/native.jpg"
        />
    )[2] => xs:base64Binary()
};


(:~
 : Endpoint to deliver a single plain text version of the
 : tei:text[@type = "transcription"] section a given document.
 :
 : Sample call to API: /content/3r671.txt
 :
 : @deprecated This function doesn't work properly and has been replaced with 
 : tapi:zip-text.
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/{$document}.txt")
    %rest:query-param("type", "{$type}", "transcription")
    %output:method("text")
function tapi:text-rest($document as xs:string, $type)
as item()+ {
    let $text := tapi:get-TEI-text($document, $type)
    let $TEI :=
        element tei:TEI {
            $text
        }
    return
        ( 
            $commons:responseHeader200,
            coll:make-plain-text-from-chunk($TEI)
        )
};

(:~
 : Endpoint to deliver all plain texts in a zip container. This comes in handy
 : e.g. for applications doing text analysis.
 :
 : @return The response header as well as a xs:base64Binary (the ZIP file)
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/ahikar-plain-text.zip")
    %output:method("binary")
function tapi:text-rest() as item()+ {
    let $prepare := coll:main()
    return
        $commons:responseHeader200,
        tapi:compress-to-zip()
};


(:~
 : Compressing all manuscripts available to ZIP.
 : 
 : @return the zipped files as xs:base64Binary
 :)
declare function tapi:compress-to-zip()
as xs:base64Binary* {
    compression:zip(xs:anyURI($commons:tg-collection || "/txt/"), false())
};


(:~
 : Returns the tei:text of a document as indicated by the @type parameter.
 : 
 : Due to the structure of the Ahikar project we can pass either an edition or
 : an XML file to the API endpoint for plain text creation.
 : This function determines the correct file which serves as a basis for the plain text.
 : 
 : @param $document The URI of a resource
 : @param $type Indicates the @type of tei:text to be processed
 : @return The tei:text element to be serialized as plain text
 :)
declare function tapi:get-TEI-text($document as xs:string, $type as xs:string)
as element(tei:text) {
    let $format := tapi:get-format($document)
    return
        if ($format = "text/xml") then
            doc($commons:data || $document || ".xml")//tei:text[@type = $type]
        (: in this case the document is an edition which forces us to pick the
        text/xml file belonging to it :)
        else
            let $xml := tapi:get-tei-file-name-of-edition($document)
            return
                 tapi:get-text-of-type($xml, $type)
};

declare function tapi:get-tei-file-name-of-edition($document as xs:string)
as xs:string {
    let $aggregates := tapi:get-edition-aggregates-without-uri-namespace($document)
    return
        tapi:find-xml-in-aggregates($aggregates)
};

declare function tapi:get-edition-aggregates-without-uri-namespace($document as xs:string)
as xs:string+ {
    let $edition := doc($commons:agg || $document || ".xml")
    for $agg in $edition//ore:aggregates/@rdf:resource return
        replace($agg, "textgrid:", "")
};

declare function tapi:find-xml-in-aggregates($aggregates as xs:string+)
as xs:string {
    for $agg in $aggregates return
        if (tapi:get-format($agg) = "text/xml") then
            $agg
        else
            ()
};

declare function tapi:get-text-of-type($uri as xs:string, $type as xs:string)
as element(tei:text) {
    doc($commons:data || $uri || ".xml")//tei:text[@type = $type]
};

(:~
 : Returns the TextGrid metadata type of a resource.
 : 
 : @param $uri The URI of the resource
 : @return The resource's format as tgmd:format
 :)
declare function tapi:get-format($uri as xs:string) as xs:string {
    doc($commons:meta || $uri || ".xml")//tgmd:format
};


declare function tapi:add-IDs($tei as element(tei:TEI)) as element(tei:TEI) {
    tapi:add-IDs-recursion($tei)
};

declare function tapi:add-IDs-recursion($nodes as node()*) as node()* {
    util:log-system-out($nodes),
    for $node in $nodes return
        typeswitch ($node)
        
        case text() return
            $node
            
        case comment() return
            ()
            
        case processing-instruction() return
            $node
            
        default return
            element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
                attribute id {generate-id($node)},
                $node/@*,
                tapi:add-IDs-recursion($node/node())
            }
};
