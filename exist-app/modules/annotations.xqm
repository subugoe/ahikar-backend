xquery version "3.1";

(:~
 : This module provides the Annotation Layer via TextAPI for Ahikar.
 :
 : @author Michelle Weidling
 : @version 1.8.1
 : @since 1.7.0
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/
 : :)

module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace functx = "http://www.functx.com";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "tapi-html.xqm";

declare variable $anno:ns := "http://ahikar.sub.uni-goettingen.de/ns/annotations";
declare variable $anno:server :=
    if(try {
    requestr:hostname() = "existdb"
} catch * {
    true()
})
    then doc("../expath-pkg.xml")/*/@name => replace("/$", "")
    else "http://localhost:8094/exist/restxq";

declare variable $anno:annotationElements := 
    (
        "placeName",
        "persName"
    );

(: this variable holds a map with the complete project structure (excluding images) :)
declare variable $anno:uris :=
    let $main-edition-object := 
        if (doc-available($commons:agg || "3r132.xml")) then
            "3r132"
        (: this main edition object is for testing purposes :)
        else
            "sample_main_edition"
    
    let $language-aggs := commons:get-available-aggregates($main-edition-object)
    return
        map { $main-edition-object:
                (: level 1: language aggregations :)
                map:merge(for $lang in $language-aggs return
                map:entry($lang, 
                    (: level 2 (key): editions associated to a language aggregation :)
                    map:merge(
                            let $editions := commons:get-available-aggregates($lang)
                            for $uri in $editions return
                                (: level 2 (value): XML associated with edition :)
                                let $edition-parts := commons:get-available-aggregates($uri)
                                for $part in $edition-parts
                                return
                                    if (anno:is-resource-xml($part)) then
                                        map:entry($uri, $part)
                                    else
                                        ()
                    )
                ))
        }
;

(:~
 : Returns annotation information about a single collection. Although this works for all collections,
 : it has mainly been designed for Ahikar's main collection, 3r132.
 : 
 : For retrieving annotation information about other collections cf. the endpoint
 : /annotations/ahikar/{$collection}/{$document}/annotationCollection.json
 : 
 : @param $collection The URI of the collection, e.g. '3r132'
 : @return An Annotation Collecion for the given collection
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/annotations/ahikar/{$collection}/annotationCollection.json")
    %output:method("json")
function anno:collection-rest($collection as xs:string) {
    if (anno:are-resources-available($collection)) then
        ($commons:responseHeader200,
        anno:make-annotationCollection($collection, (), $anno:server))
    else
        anno:get-404-header($collection)
};


(:~
 : A generic function for creating an W3C compliant Annotation Collection for a given resource.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : 
 : @param $collection The URI of a Collection Object
 : @param $document The URI of a Collection or Manifest Object. May be an empty sequence if only information about the $collection should be created
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 : @return A map with all information necessary for the Annotation Collection
 :)
(: ## tested ## :)
declare function anno:make-annotationCollection($collection as xs:string,
    $document as xs:string?,
    $server as xs:string)
as map() {
    (: if $document is a collection then its value in $anno:uris is a map containing the aggregated manifests.
    at this point it is relevant if $document is actually a manifest or a collection.
    we have to create different paths containing $first and $last for the two of them,
    namely
        $server || "/annotations/ahikar/" || $document || "/" || $first || "/annotationPage.json" for $document being a collection
        $server || "/annotations/ahikar/" || $collection || "/" || $document || "/" || $first || "/annotationPage.json" for $document being a manifest :)
    if ($document and anno:find-in-map($anno:uris, $document) instance of map()) then
        anno:get-information-for-collection-object($document, $server)
    
    (: if $document is a manifest then its value in $anno:uris are xs:string representations of the edition's URIs
    since we are on the lowest level of the map. :)
    else if($document) then
        let $tei := anno:find-in-map($anno:uris, $document)
        let $pages := anno:get-pages-in-TEI($tei)
        let $title := anno:get-metadata-title($document)
        let $first-entry := $server || "/api/annotations/ahikar/" || $collection || "/" || $document || "/" || $pages[1] || "/annotationPage.json"
        let $last-entry := $server || "/api/annotations/ahikar/" || $collection || "/" || $document || "/" || $pages[last()] || "/annotationPage.json"
    
        return
            anno:make-annotationCollection-map($document, $title, $first-entry, $last-entry)
                    
    (: in case we only have $collection and $document isn't set :)
    else
        anno:get-information-for-collection-object($collection, $server)
};


(:~
 : Gets all the information that is necessary for creating an Annotation Collection for a Collection Object.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : 
 : @param $collectionURI The URI of the current Collection Object
 : @param The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 : @return A map with all information necessary for the Annotation Collection
 :)
(: ## tested ## :)
declare function anno:get-information-for-collection-object($collectionURI as xs:string,
    $server as xs:string)
as map() {
    let $child-keys := anno:find-in-map($anno:uris, $collectionURI) => map:keys()
    let $first := $child-keys[1]
    let $last := $child-keys[last()]
    let $title := anno:get-metadata-title($collectionURI)
    let $first-entry := $server || "/api/annotations/ahikar/" || $collectionURI || "/" || $first || "/annotationPage.json"
    let $last-entry := $server || "/api/annotations/ahikar/" || $collectionURI || "/" || $last || "/annotationPage.json"

    return
        anno:make-annotationCollection-map($collectionURI, $title, $first-entry, $last-entry)
};


(:~
 : Returns a resource's title as given in the TextGrid metadata.
 : 
 : @param $uri The resource's URI
 : @return The resource's title
 :)
(: ## tested ## :)
declare function anno:get-metadata-title($uri as xs:string)
as xs:string {
    commons:get-document($uri, "meta")//tgmd:title/string()
};


(:~
 : Creates a map containing all information necessary for a W3C compliant Annotation Collection.
 : 
 : @param $uri The resource's URI
 : @param $title The resource's title
 : @param $first-entry The IRI of the first Annotation Page that is included within the Collection
 : @param $last-entry The IRI of the last Annotation Page that is included within the Collection
 :)
(: ## tested ## :)
declare function anno:make-annotationCollection-map($uri as xs:string,
    $title as xs:string,
    $first-entry as xs:string,
    $last-entry as xs:string)
as map() {
    map {
        "annotationCollection":
            map {
                "@context": "http://www.w3.org/ns/anno.jsonld",
                "id":       $anno:ns || "/annotationCollection/" || $uri,
                "type":     "AnnotationCollection",
                "label":    "Ahikar annotations for textgrid:" || $uri || ": " || $title,
                "x-creator":  anno:get-creator($uri),
                "total":    anno:get-total-no-of-annotations($uri),
                "first":    $first-entry,
                "last":     $last-entry
            }
    }
};

(:~
 : Extracts the current edition's editor(s) from the TEI metadata.
 : In case the URI of a collection or edition is passed, the aggregated TEI/XML
 : files are used for determining the creator(s).
 : 
 : @param $uri The URI of the resource, e.g. '3rx14'
 : @return A string containing the creators of the annotations as stated in the
 : TEI header of the (underlying) resource(s).
 :)
(: ## tested ## :)
declare function anno:get-creator($uri as xs:string)
as xs:string {
    let $xmls :=
        if (anno:is-resource-xml($uri)) then
            $uri
        else if(anno:is-resource-edition($anno:uris, $uri)) then
            anno:find-in-map($anno:uris, $uri)
        else
            let $map := anno:find-in-map($anno:uris, $uri)
            return
                anno:get-all-xml-uris-for-submap($map)
    let $creators := for $xml in $xmls return
        let $doc := commons:get-document($xml, "data")
        return $doc//tei:teiHeader//tei:editor
    return
        distinct-values($creators) => string-join(", ")
};


(:~
 : Returns the Annotation Page of a given Collection Object according to W3C.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/annotationPage.json")
    %output:method("json")
function anno:annotationPage-for-collection-rest($collection as xs:string, 
$document as xs:string) {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationPage($collection, $document, $anno:server))
        
    else
        anno:get-404-header(($collection, $document))
};


(:~
 : A generic function for creating an W3C compliant Annotation Page for a given resource.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of a Collection Object, e.g. '3r132'
 : @param $document The URI of a Collection or Manifest Object, e.g. '3r84g'
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 : @return A map with all information necessary for the Annotation Collection
 :)
(: ## tested ## :)
declare function anno:make-annotationPage($collection as xs:string, 
    $document as xs:string,
    $server as xs:string)
as map() {
    let $nextPage := anno:get-prev-or-next-annotationPage-ID($collection, $document, "next")
    let $prevPage := anno:get-prev-or-next-annotationPage-ID($collection, $document, "prev")

    let $xmls :=
        if(anno:is-resource-edition($anno:uris, $document)) then
            anno:find-in-map($anno:uris, $document)
        else
            anno:find-in-map($anno:uris, $document) => anno:get-all-xml-uris-for-submap()
    let $annotations :=
        for $xml in $xmls return
            for $page in anno:get-pages-in-TEI($xml)return
                anno:get-annotations($xml, $page)
    
    return
        map {
            "annotationPage":
                map {
                    "@context":     "http://www.w3.org/ns/anno.jsonld",
                    "id":           $anno:ns || "/annotationPage/" || $collection || "/" || $document,
                    "partOf":       map {
                                        "id": $anno:ns || "/annotationCollection/" || $collection,
                                        "label": "Ahikar annotations for " || $collection,
                                        "total": anno:get-total-no-of-annotations($collection)
                                    },
                    "next":         anno:get-prev-or-next-annotationPage-url($collection, $nextPage, (), $server),
                    "prev":         anno:get-prev-or-next-annotationPage-url($collection, $prevPage, (), $server),
                    "startIndex":   anno:determine-start-index($document),
                    "items":        $annotations
                }
        }
};


(:~
 : Returns the Annotation Collection of a given Collection or Manifest Object according to W3C.
 : 
 : The Collection Object given by $collection mainly serves for identification and compliance
 : with the TextAPI.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @return An Annotation Collecion for the given Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/annotationCollection.json")
    %output:method("json")
function anno:manifest-rest($collection as xs:string, 
$document as xs:string) {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationCollection($collection, $document, $anno:server))
        
    else
        anno:get-404-header(($collection, $document))
};


(:~
 : Returns the Annotation Collection of a given Collection or Manifest Object according to W3C.
 : 
 : The Collection Object given by $collection mainly serves for identification and compliance
 : with the TextAPI.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @return An Annotation Collection for the given Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/{$page}/annotationCollection.json")
    %output:method("json")
function anno:annotationCollection-for-manifest-rest($collection as xs:string, 
$document as xs:string, $page as xs:string) {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationCollection-for-manifest($collection, $document, $page, $anno:server))
        
    else
        anno:get-404-header(($collection, $document))
};


(:~
 : A function for creating an W3C compliant Annotation Collection for a given page
 : in a Manifest Object.
 : Since we do not need a 'last' field and have a different reference for the
 : total amount of annotations, this isn't handled by the generic function for
 : creating Annotation Collections.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 :)
(: ## tested ## :)
declare function anno:make-annotationCollection-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    let $title := anno:get-metadata-title($collection)

    return
        map {
            "annotationCollection":
                map {
                    "@context": "http://www.w3.org/ns/anno.jsonld",
                    "id":       $anno:ns || "/annotationCollection/" || $document || "/" || $page,
                    "type":     "AnnotationCollection",
                    "label":    "Ahikar annotations for textgrid:" || $document || ": " || $title || ", page " || $page,
                    "x-creator":  anno:get-creator($document),
                    "total":    anno:get-total-no-of-annotations($page),
                    "first":    $server || "/api/annotations/ahikar/" || $collection || "/" || $document || "/" || $page || "/annotationPage.json"
                }
        }
};


(:~
 : Returns the Annotation Page of a given Collection or Manifest Object according to W3C.
 : 
 : The Collection Object given by $collection mainly serves for identification and compliance
 : with the TextAPI.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @return An Annotation Page for the given Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/{$page}/annotationPage.json")
    %output:method("json")
function anno:annotationPage-for-manifest-rest($collection as xs:string, 
    $document as xs:string,
    $page as xs:string)
as element()+ {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationPage-for-manifest($collection, $document, $page, $anno:server))
        
    else
        anno:get-404-header(($collection, $document))
};


(:~
 : A function for creating an W3C compliant Annotation Page for a given Manifest Object.
 : Since we need a slightly different string for the 'next' and 'prev' fields, this
 : isn't handled by the generic function for creating Annotation Pages.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 :)
(: ## tested ## :)
declare function anno:make-annotationPage-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    let $docTitle := anno:get-metadata-title($document)
    let $xml := anno:find-in-map($anno:uris, $document)
    let $prevPage := anno:get-prev-or-next-page($document, $page, "prev")
    let $nextPage := anno:get-prev-or-next-page($document, $page, "next")
    
    let $nextPageURL :=
        if ($nextPage) then
            anno:get-prev-or-next-annotationPage-url($collection, $document, $nextPage, $server)
        else
            ()
    let $prevPageURL :=
        if ($prevPage != "") then
            anno:get-prev-or-next-annotationPage-url($collection, $document, $prevPage, $server)
        else
            ()
    
    return
        map {
            "annotationPage":
                map {
                    "@context":     "http://www.w3.org/ns/anno.jsonld",
                    "id":           $anno:ns || "/annotationPage/" || $collection || "/" || $document || "-" || $page,
                    "type":         "AnnotationPage",
                    "partOf":       map {
                                        "id": $anno:ns || "/annotationCollection/" || $document,
                                        "label": "Ahikar annotations for textgrid:" || $document || ": " || $docTitle,
                                        "total": anno:get-total-no-of-annotations($document)
                                    },
                    "next":         $nextPageURL,
                    "prev":         $prevPageURL,
                    "startIndex":   anno:determine-start-index-for-page($document, $page),
                    "items":        anno:get-annotations($xml, $page)
                }
        }
};


(:~
 : Gets the annotations for a given page.
 : 
 : At this stage, TEI files are scraped for person and place names.
 : 
 : @param $teixml-uri The XML's URI.
 : @param $page The page within an XML file, i.e. a tei:pb/@n within a TEI resource
 :)
(: ## tested ## :)
declare function anno:get-annotations($teixml-uri as xs:string,
    $page as xs:string)
as map()+ {
    let $pageChunk := anno:get-page-fragment($teixml-uri, $page)
    
    let $annotation-elements := 
        for $name in $anno:annotationElements return
            $pageChunk//*[name(.) = $name]
    
    for $annotation in $annotation-elements return
        let $id := string( $annotation/@id ) (: get the predefined ID from the in-memory TEI with IDs :)
        return
            map {
                "id": $anno:ns || "/" || $teixml-uri || "/annotation-" || $id,
                "type": "Annotation",
                "bodyValue": anno:get-bodyValue($annotation),
                "target": anno:get-target-information($annotation, $teixml-uri, $id)
            }
};


(:~
 : Returns a single page from a TEI resource, i.e. all content from the given $page
 : up to the next page break.
 : 
 : @param $documentURI The resource's URI. Attention: This refers to the TEI file itself!
 : @param $page The page to be returned as tei:pb/@n/string()
 :)
(: ## tested ## :)
declare function anno:get-page-fragment($documentURI as xs:string,
    $page as xs:string)
as element(tei:TEI) {
    let $nodeURI := commons:get-document($documentURI, "data")/base-uri()
    return
        tapi-html:get-page-fragment($nodeURI, $page)
};


(:~
 : Returns the number of annotations belonging to a given $uri. In case this $uri is
 : a collection, all TEI files belonging to this collection are considered for the
 : computation.
 : 
 : @param $uri The resource's URI
 : @return The number of annotations that are associated with the $uri
 :)
(: ## tested ## :)
declare function anno:get-total-no-of-annotations($uri as xs:string)
as xs:integer {
    let $map-entry-for-uri := anno:find-in-map($anno:uris, $uri)
    
    let $xmls :=
        if (anno:is-resource-edition($anno:uris, $uri)) then
            $map-entry-for-uri
        else
            anno:get-all-xml-uris-for-submap($map-entry-for-uri)
            
    let $annotation-no-per-xml :=
        for $xml in $xmls return
            let $doc := commons:get-document($xml, "data")
            let $noOfElementsEach :=
                for $element in $anno:annotationElements return
                    count($doc//tei:text//*[name(.) = $element])
            return
                sum($noOfElementsEach)
    return sum($annotation-no-per-xml)
};


(:~
 : Returns all TEI files that belong to a map. Technically, this function returns
 : all values of the lowest map level.
 : 
 : @param $map A part of the $anno:uris map
 : @return All values of the lowest $map level
 :)
(: ## tested ## :)
declare function anno:get-all-xml-uris-for-submap($map as map())
as xs:string* {
    let $get-values := function($key, $value){$value}
    
    for $value in map:for-each($map, $get-values) return
        if ($value instance of map()) then
             anno:get-all-xml-uris-for-submap($value)
        (: this condition ensures that TEI/XMLs that have been deleted or aren't
        available for some other reason are not considered :)
        else if(doc-available($commons:data || $value || ".xml")) then
            $value
        else
            ()
};


(:~
 : Returns the target segment for an annotation.
 : 
 : @param $annotation The node which serves as a basis for the annotation
 : @param $documentURI The resource's URI to which the $annotation belongs to
 : @param $id The node ID of the annotation. It is equivalent to generate-id($annotation)
 : @return A map containing the target information
 :)
(: ## tested ## :)
declare function anno:get-target-information($annotation as node(),
    $documentURI as xs:string,
    $id as xs:string)
as map(*) {
    map {
        "id": $anno:ns || "/" || $documentURI || "/"|| $id,
        "format": "text/xml",
        "language": $annotation/ancestor-or-self::*[@xml:lang][1]/@xml:lang/string()
    }
};


(:~
 : Returns the bodyValue's content for an annotation.
 : 
 : @see https://www.w3.org/TR/annotation-model/#string-body
 : 
 : @param $annotation The node which serves as a basis for the annotation
 : @return The content of bodyValue.
 :)
(: ## tested ## :)
declare function anno:get-bodyValue($annotation as node())
as xs:string {
    switch ($annotation/local-name())
        case "persName" return "A person's name."
        case "placeName" return "A place's name."
        default return ()
};


(:~
 : Checks if a (sequence of) resource(s) is available in the database.
 : 
 : @param $resources The URI of the resources to be checked
 : @return true() if all resources are available
 :)
(:  ## tested ## :)
declare function anno:are-resources-available($resources as xs:string+)
as xs:boolean {
    let $availability :=
        for $resource in $resources return
            doc-available($commons:meta || $resource || ".xml")
    return
        not(functx:is-value-in-sequence(false(), $availability))
};


(:~
 : Creates a HTTP 404 header containing information about missing resources.
 : This function is called whenever an API call is made but at least one of the
 : requested resources isn't available.
 : 
 : @param $resources The URIs of resource's requested in an API call
 : @return The response header
 :)
(:  ## tested ## :)
declare function anno:get-404-header($resources as xs:string+) {
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" 
            status="404"
            message="One of the following requested resources couldn't be found: {string-join($resources, ", ")}">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>
};


(:~
 : Returns the value of a key which can be on an arbitrary level of a nested map.
 : Thus it corresponds to the map:find function which hasn't been implemented in
 : eXist-db.
 : 
 : The function recursively traverses a map to find a key on any level.
 : 
 : @param $map The map in which the key's value has to be found
 : @param $key The key whose value is to be returned
 : @return The value of the given $key
 :)
(: ## tested ## :)
declare function anno:find-in-map($map as map(),
    $key as xs:string)
as item()? {
    let $get-values := function($key, $value){$value}
    return
        if (map:keys($map) = $key) then
            $map?($key)
        else
            let $keys-of-current-map := map:keys($map)

            for $value in map:for-each($map, $get-values) return
                (: in this case we aren't at the bottom level yet, but the
                $key hasn't been found yet. the value of the current key is
                a map which has to be searched for the $key :)
                if ($value instance of map()) then
                    anno:find-in-map($value, $key)
                (: in this case we are already at the bottom level and the
                $key hasn't matched in this branch:)
                else
                    ()
};


(:~
 : Returns the previous or following Annotation Page as indicated by the $type
 : parameter.
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of the Collection or Manifest Object
 : @param $type "prev" for getting the previous page, "next" for getting the next page
 : @return 
 :)
(: ## tested ## :)
declare function anno:get-prev-or-next-annotationPage-ID($collection as xs:string,
    $document as xs:string,
    $type as xs:string)
as xs:string? {
    let $collection-keys := anno:find-in-map($anno:uris, $collection) => map:keys()
    return
        anno:get-prev-or-next($collection-keys, $document, $type)
};

(: ## tested ## :)
declare function anno:get-prev-or-next($entities as item()+,
    $searched-for as xs:string,
    $type as xs:string)
as xs:string? {
    let $no-of-entities := count($entities)
    let $position-of-searched-for := index-of($entities, $searched-for)
    let $new-position := 
        if ($type = "prev") then
            $position-of-searched-for - 1
        else
            $position-of-searched-for + 1
    return
        if ($new-position le $no-of-entities
        and ($type = "prev"
        and $new-position != 0
        or
        $type = "next")) then
            $entities[$new-position]
        else
            ()
};

(: ## tested ## :)
declare function anno:get-prev-or-next-annotationPage-url($collection as xs:string,
    $document as xs:string?,
    $page as xs:string?,
    $server as xs:string)
as xs:string? {
    let $pageSuffix :=
        if ($page) then
            "/" || $page
        else
            ()
    return
        if ($document) then
            $server || "/api/annotations/ahikar/" || $collection|| "/" || $document || $pageSuffix || "/annotationPage.json"
        else
            ()
};

(:~
 : Checks if a given resource is a TEI/XML.
 : 
 : @param $uri The resource's URI
 : @return true() if resources stated by $uri is a TEI/XML resource
 :)
 (: ## tested ## :)
declare function anno:is-resource-xml($uri as xs:string) as xs:boolean {
    commons:get-document($uri, "meta")//tgmd:format = "text/xml"
};

(:~ 
 : Checks if the URI to a given resource belongs to an edition object. In this
 : case, its entry in $anno:uris isn't a map but a simple xs:string denoting the
 : URI of the corresponding TEI/XML.
 : 
 : @param $uri The resource's URI
 : @return true() if resources stated by $uri is an edition object
 :)
(: ## tested ## :)
declare function anno:is-resource-edition($map as map(),
    $uri as xs:string)
as xs:boolean {
    not(anno:find-in-map($map, $uri) instance of map())
};

(:~
 : Returns all page break numbers for a given TEI resource.
 : 
 : @param $documentURI The TEI resource's URI
 : @return A sequence of all page breaks occuring in the resource
 :)
 (: ## tested ## :)
declare function anno:get-pages-in-TEI($documentURI as xs:string) as xs:string+ {
    commons:get-document($documentURI, "data")//tei:pb[@facs]/@n/string()
};


(:~
 : Returns the previous or next @n of a tei:pb seen from a given tei:pb which is
 : denoted in $page.
 : 
 : @param $manifest-uri The current manifest's URI
 : @param $page The @n attribute of the current page break/tei:pb
 : @param $type "prev" for the previous, "next" for the next page break
 :)
(: ## tested ## :)
declare function anno:get-prev-or-next-page($manifest-uri as xs:string,
    $page as xs:string, 
    $type as xs:string)
as xs:string? {
    let $tei := anno:find-in-map($anno:uris, $manifest-uri)
    let $pages := anno:get-pages-in-TEI($tei)
    return
        anno:get-prev-or-next($pages, $page, $type)
};


(:~
 : In order to determine the startIndex value on an Annotation Page, we have to
 : compute the number of annotations that are part of previous Annotation Pages
 : in an Annotation Collection. For this we need a list of URIs that belong to
 : TEI/XMLs that appear before the given resource.
 : 
 : Since XMLs are parts of editions, we have to differentiate between them.
 : 
 : @param $uri The URI of the current resource. This may refer to a edition or TEI/XML.
 : @return A list of URIs that appear before the given resource in a collection 
 :)
(: ## tested ## :)
declare function anno:get-xmls-prev-in-collection($uri as xs:string)
as xs:string* {
    if (anno:is-resource-xml($uri)) then
            let $edition := anno:get-parent-aggregation($uri)
            return
                anno:get-prev-xml-uris($edition)
    else if(anno:is-resource-edition($anno:uris, $uri)) then
        anno:get-prev-xml-uris($uri)
    else
        ()
};


(:~
 : In order to determine the startIndex value on an Annotation Page, we have to
 : compute the number of annotations that are part of previous Annotation Pages
 : in an Annotation Collection. For this we need a list of URIs that belong to
 : TEI/XMLs that appear before the given resource.
 : 
 : This function accepts the URI of a edition and determines the URIs of all XMLs
 : that are part of editions which appear before the $uri in the aggregating
 : collection.
 : 
 : @param $uri The URI of the current edition
 : @return A list of all URIs of TEI resources that appear before the given edition in a collection 
 :)
(: ## tested ## :)
declare function anno:get-prev-xml-uris($uri as xs:string)
as xs:string* {
    let $collection := anno:get-parent-aggregation($uri)
    let $collection := commons:get-document($collection, "agg")
    
    let $tgURI := "textgrid:" || $uri
    let $tgURINode := $collection//@rdf:resource[./string() = $tgURI]
    let $prevEditions := $collection//@rdf:resource[. << $tgURINode]
    let $prevEditionsURIs := 
        for $edition in $prevEditions return
            replace($edition, "textgrid:", "")
    
    for $edition in $prevEditionsURIs return
        anno:find-in-map($anno:uris, $edition)
};


(:~
 : Return the parent aggregation of a given URI.
 : 
 : @param $uri The resource's URI
 : @return The URI of the given resource's parent aggregation
 :)
(: ## tested ## :)
declare function anno:get-parent-aggregation($uri as xs:string)
as xs:string? {
    if (collection($commons:agg)[.//@rdf:resource = "textgrid:" || $uri]) then
        collection($commons:agg)[.//@rdf:resource = "textgrid:" || $uri]
        => base-uri()
        => substring-after("agg/")
        => substring-before(".xml")
    else
        ()
};


(:~
 : Start indices are relevant for Annotation Pages and state the relative position
 : of the first annotation item as seen from the superordinate Annotation
 : Collection. This function determines the start index for a given collection,
 : edition or TEI/XML.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @param $uri The URI of the given resource. This may refer to a collection or
 : an edition.
 : @return The relative position of the first annotation
 :)
(: ## tested ## :)
declare function anno:determine-start-index($uri as xs:string)
as xs:integer {
    let $resourceType := commons:get-document($uri, "meta")//tgmd:format
    return
        if ($resourceType = "text/tg.aggregation+xml") then
            let $project := anno:get-parent-aggregation($uri)
            let $nodeForURI := commons:get-document($project, "agg")//*[@rdf:resource[matches(., $uri)]]
            let $prevCollections := commons:get-document($project, "agg")//*[@rdf:resource[. << $nodeForURI]]/@rdf:resource
            let $prevCollections :=
                for $collURI in $prevCollections return
                    replace($collURI, "textgrid:", "")
            let $noOfAnnotationsPerCollection :=
                for $collURI in $prevCollections return
                    anno:get-total-no-of-annotations($collURI)
            return
                sum($noOfAnnotationsPerCollection)
        else
            let $prevXMLs := anno:get-xmls-prev-in-collection($uri)
            let $noOfAnnotationsPerXML :=
                for $xml in $prevXMLs return
                    let $doc := commons:get-document($xml, "data")
                    let $noOfAnnotationsPerElement :=
                        for $name in $anno:annotationElements return
                            count($doc//tei:text//*[name(.) = $name])
                    return
                        sum($noOfAnnotationsPerElement)
            return
                sum($noOfAnnotationsPerXML)
};


(:~
 : Start indices are relevant for Annotation Pages and state the relative position
 : of the first annotation item as seen from the superordinate Annotation
 : Collection. In this case, the superordinate Annotation Collection handles a
 : XML file, and this function returns the start index for a page in a TEI/XML.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @param $uri The URI of the given resource. This may refer to an edition.
 : @param $page The @n attribute of the current tei:pb
 : @return The relative position of the first annotation
 :)
(: ## tested ## :)
declare function anno:determine-start-index-for-page($uri as xs:string,
    $page as xs:string)
as xs:integer {
    let $xml := anno:find-in-map($anno:uris, $uri)
    let $doc := commons:get-document($xml, "data")
    let $currentPb := $doc//tei:pb[@n = $page and @facs]
    let $noOfAnnotationsPerElement :=
        for $name in $anno:annotationElements return
            count($doc//*[name(.) = $name][.[ancestor::tei:text[1] = $currentPb/ancestor::tei:text[1]] << $currentPb])
    return
        sum($noOfAnnotationsPerElement)
};
