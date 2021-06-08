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
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";
import module namespace edit="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial" at "editorial.xqm";
import module namespace functx = "http://www.functx.com";
import module namespace me="http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion" at "/db/apps/ahikar/modules/motifs-expansion.xqm";
import module namespace motifs="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs" at "motifs.xqm";

(:
 : Determines the correct language aggregations.
 : The ones starting with "sample_" are for testing only.
 :)
declare variable $anno:lang-aggs := 
    map {
        "syriac": if (doc-available($commons:agg || "3r84g.xml")) then "3r84g" else "sample_lang_aggregation_syriac",
        "arabic-karshuni":
            if (doc-available($commons:agg || "3r84h.xml")
            and doc-available($commons:agg || "3r9ps.xml")) then ("3r84h", "3r9ps") else ("sample_lang_aggregation_arabic", "sample_lang_aggregation_karshuni")
    };

(: this variable holds a map with the complete project structure (excluding images) :)
declare variable $anno:uris :=
    let $main-edition-object := 
        if (doc-available($commons:agg || "3r132.xml")) then
            "3r132"
        (: this main edition object is for testing purposes :)
        else
            "sample_main_edition"
    
    let $views := ("syriac", "arabic-karshuni")
    return
        map { $main-edition-object:
                (: level 1: language aggregations :)
                map:merge(for $view in $views return
                map:entry($view, 
                    (: level 2 (key): editions associated to a language aggregation :)
                    map:merge(
                        let $language-aggregates := anno:get-lang-aggregation-uris($view)
                            for $lang in $language-aggregates return
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

declare function anno:get-lang-aggregation-uris($collection-type as xs:string)
as xs:string+ {
    $anno:lang-aggs?($collection-type)
};

(:~
 : A generic function for creating an W3C compliant Annotation Collection for a given resource.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : 
 : @param $collection The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param $document The URI of a Collection or Manifest Object. May be an empty sequence if only information about the $collection should be created
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 : @return A map with all information necessary for the Annotation Collection
 :)
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
        let $pages := commons:get-pages-in-TEI($tei)
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
 : @param $collection-type The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 : @return A map with all information necessary for the Annotation Collection
 :)
declare function anno:get-information-for-collection-object($collection-type as xs:string,
    $server as xs:string)
as map() {
    let $child-keys := anno:find-in-map($anno:uris, $collection-type) => map:keys()
    let $first := $child-keys[1]
    let $last := $child-keys[last()]
    let $title := anno:make-collection-object-title($collection-type)
    let $first-entry := $server || "/api/annotations/ahikar/" || $collection-type || "/" || $first || "/annotationPage.json"
    let $last-entry := $server || "/api/annotations/ahikar/" || $collection-type || "/" || $last || "/annotationPage.json"

    return
        anno:make-annotationCollection-map($collection-type, $title, $first-entry, $last-entry)
};

declare function anno:make-collection-object-title($collection-type as xs:string)
as xs:string {
    switch ($collection-type)
        case "syriac" return "The Syriac Collection"
        case "arabic-karshuni" return "The Arabic and Karshuni Collections"
        default return anno:get-metadata-title($collection-type)
};


(:~
 : Returns a resource's title as given in the TextGrid metadata.
 : 
 : @param $uri The resource's URI
 : @return The resource's title
 :)
declare function anno:get-metadata-title($uri as xs:string)
as xs:string {
    commons:get-document($uri, "meta")//tgmd:title/string()
};


(:~
 : Creates a map containing all information necessary for a W3C compliant Annotation Collection.
 : 
 : @param $collection Either the type of the collection (syriac or arabic-karshuni) or the collection URI of an edition.
 : @param $title The resource's title
 : @param $first-entry The IRI of the first Annotation Page that is included within the Collection
 : @param $last-entry The IRI of the last Annotation Page that is included within the Collection
 :)
declare function anno:make-annotationCollection-map($collection as xs:string,
    $title as xs:string,
    $first-entry as xs:string,
    $last-entry as xs:string)
as map() {
        map {
            "annotationCollection":
                map {
                    "@context": "http://www.w3.org/ns/anno.jsonld",
                    "id":       $commons:anno-ns || "/annotationCollection/" || $collection,
                    "type":     "AnnotationCollection",
                    "label":    "Ahikar annotations for textgrid:" || $collection || ": " || $title,
                    "x-creator":  anno:get-creator($collection),
                    "first":    $first-entry,
                    "last":     $last-entry
                }
        }
};


declare function anno:determine-uris-for-collection($collection as xs:string)
as xs:string+ {
    switch ($collection)
        case "syriac" return $anno:lang-aggs?($collection)
        case "arabic-karshuni" return $anno:lang-aggs?($collection)
        default return $collection
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
 : A generic function for creating an W3C compliant Annotation Page for a given resource.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param $document The URI of a Collection or Manifest Object, e.g. '3r84g'
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 : @return A map with all information necessary for the Annotation Collection
 :)
declare function anno:make-annotationPage($collection as xs:string, 
    $document as xs:string,
    $server as xs:string)
as map() {
    let $nextPage := anno:get-prev-or-next-annotationPage-ID($collection, $document, "next")
    let $prevPage := anno:get-prev-or-next-annotationPage-ID($collection, $document, "prev")

    let $xml-uris :=
        if(anno:is-resource-edition($anno:uris, $document)) then
            anno:find-in-map($anno:uris, $document)
        else
            anno:find-in-map($anno:uris, $document)
            => anno:get-all-xml-uris-for-submap()
    let $annotations :=
        for $teixml-uri in $xml-uris return
            for $page in commons:get-pages-in-TEI($teixml-uri) return
                anno:get-saved-items($document, $page)
    
    return
        map {
            "annotationPage":
                map {
                    "@context":     "http://www.w3.org/ns/anno.jsonld",
                    "id":           $commons:anno-ns || "/annotationPage/" || $collection || "/" || $document,
                    "partOf":       map {
                                        "id": $commons:anno-ns || "/annotationCollection/" || $collection,
                                        "label": "Ahikar annotations for " || $collection
                                    },
                    "next":         anno:get-prev-or-next-annotationPage-url($collection, $nextPage, (), $server),
                    "prev":         anno:get-prev-or-next-annotationPage-url($collection, $prevPage, (), $server),
                    "items":        $annotations
                }
        }
};

(:~
 : A function for creating an W3C compliant Annotation Collection for a given page
 : in a Manifest Object.
 : Since we do not need a 'last' field, this isn't handled by the generic function for
 : creating Annotation Collections.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 :)
declare function anno:make-annotationCollection-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    let $title := anno:get-metadata-title($document)

    return
        map {
            "annotationCollection":
                map {
                    "@context": "http://www.w3.org/ns/anno.jsonld",
                    "id":       $commons:anno-ns || "/annotationCollection/" || $document || "/" || $page,
                    "type":     "AnnotationCollection",
                    "label":    "Ahikar annotations for textgrid:" || $document || ": " || $title || ", page " || $page,
                    "x-creator":  anno:get-creator($document),
                    "first":    $server || "/api/annotations/ahikar/" || $collection || "/" || $document || "/" || $page || "/annotationPage.json"
                }
        }
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
 : @param $collection The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @param $server The server we are currently on. This mainly serves testing purposes and usually defaults to $anno:server
 :)
declare function anno:make-annotationPage-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    let $docTitle := anno:get-metadata-title($document)
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
                    "id":           $commons:anno-ns || "/annotationPage/" || $collection || "/" || $document || "-" || $page,
                    "type":         "AnnotationPage",
                    "partOf":       map {
                                        "id": $commons:anno-ns || "/annotationCollection/" || $document,
                                        "label": "Ahikar annotations for textgrid:" || $document || ": " || $docTitle
                                    },
                    "next":         $nextPageURL,
                    "prev":         $prevPageURL,
                    "items":        anno:get-saved-items($document, $page)
                }
        }
};

declare function anno:get-saved-items($manifest as xs:string,
    $page as xs:string)
as array(*)? {
    let $filename := $commons:json || $manifest || "-" || commons:format-page-number($page) || "-items.json"
    return
        util:binary-doc($filename)
        => util:base64-decode()
        => parse-json()
        => map:get("items")
};


(:~
 : Returns all TEI files that belong to a map. Technically, this function returns
 : all values of the lowest map level.
 : 
 : @param $map A part of the $anno:uris map
 : @return All values of the lowest $map level
 :)
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
 : Checks if a (sequence of) resource(s) is available in the database.
 : 
 : @param $resources The URI of the resources to be checked
 : @return true() if all resources are available
 :)
declare function anno:are-resources-available($resources as xs:string+)
as xs:boolean {
    let $availability :=
        for $resource in $resources return
            if ($resource = ("syriac", "arabic-karshuni")) then
                for $edition in $anno:lang-aggs?($resource) return
                    doc-available($commons:meta || $edition || ".xml")
            else
                doc-available($commons:meta || $resource || ".xml")
    return
        not(functx:is-value-in-sequence(false(), $availability))
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
declare function anno:get-prev-or-next-annotationPage-ID($collection as xs:string,
    $document as xs:string,
    $type as xs:string)
as xs:string? {
    let $collection-keys := anno:find-in-map($anno:uris, $collection) => map:keys()
    return
        anno:get-prev-or-next($collection-keys, $document, $type)
};

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
declare function anno:is-resource-xml($uri as xs:string) as xs:boolean {
    doc-available($commons:data || $uri || ".xml")
    and commons:get-document($uri, "meta")//tgmd:format = "text/xml"
};

(:~ 
 : Checks if the URI to a given resource belongs to an edition object. In this
 : case, its entry in $anno:uris isn't a map but a simple xs:string denoting the
 : URI of the corresponding TEI/XML.
 : 
 : @param $uri The resource's URI
 : @return true() if resources stated by $uri is an edition object
 :)
declare function anno:is-resource-edition($map as map(),
    $uri as xs:string)
as xs:boolean {
    not(anno:find-in-map($map, $uri) instance of map())
};


(:~
 : Returns the previous or next @n of a tei:pb seen from a given tei:pb which is
 : denoted in $page.
 : 
 : @param $manifest-uri The current manifest's URI
 : @param $page The @n attribute of the current page break/tei:pb
 : @param $type "prev" for the previous, "next" for the next page break
 :)
declare function anno:get-prev-or-next-page($manifest-uri as xs:string,
    $page as xs:string, 
    $type as xs:string)
as xs:string? {
    let $tei := anno:find-in-map($anno:uris, $manifest-uri)
    let $pages := commons:get-pages-in-TEI($tei)
    return
        anno:get-prev-or-next($pages, $page, $type)
};

(:~
 : Return the parent aggregation of a given URI.
 : 
 : @param $uri The resource's URI
 : @return The URI of the given resource's parent aggregation
 :)
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
