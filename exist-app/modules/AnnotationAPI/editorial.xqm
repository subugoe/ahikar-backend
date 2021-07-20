xquery version "3.1";

(:~
 : This module provides the editorial annotations for Ahikar.
 :
 : @author Michelle Weidling
 : @version 1.8.1
 : @since 1.7.0
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/
 : :)

module namespace edit="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";

declare variable $edit:annotationElements := 
    (
        "placeName",
        "persName",
        "add",
        "del",
        "damage",
        "choice",
        "unclear",
        "cit",
        "surplus"
    );
    
(:~
 : Gets the annotations for a given page for both possible text types
 : (transcription and transliteration, if present).
 : 
 : At this stage, TEI files are scraped for person and place names.
 : 
 : @param $teixml-uri The XML's URI.
 : @param $page The page within an XML file, i.e. a tei:pb/@n within a TEI resource
 :)
declare function edit:get-annotations($pages as element(tei:TEI)+,
    $teixml-uri as xs:string)
as map()* {
    let $annotation-elements := 
        for $chunk in $pages return
            for $name in $edit:annotationElements return
                $chunk//*[name(.) = $name]
    
    for $annotation in $annotation-elements return
        edit:make-map($annotation, $teixml-uri)
};

declare function edit:make-map($annotation as element(),
    $teixml-uri as xs:string)
as map(*) {
    let $id := string( $annotation/@id ) (: get the predefined ID from the in-memory TEI with IDs :)
    return
        map {
            "id": $commons:anno-ns || "/" || $teixml-uri || "/annotation-" || $id,
            "type": "Annotation",
            "body": edit:get-body-object($annotation),
            "target": edit:get-target-information($annotation, $teixml-uri, $id)
        }
};


(:~
 : Returns the Body Object for an annotation.
 : 
 : @see https://www.w3.org/TR/annotation-model/#embedded-textual-body
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/annotation-api-specs/#body-object
 : 
 : @param $annotation The node which serves as a basis for the annotation
 : @return A map representing the embedded textual body of the annotation.
 :)
declare function edit:get-body-object($annotation as node())
as map() {
    map {
        "type": "TextualBody",
        "value": edit:get-body-value($annotation),
        "format": "text/plain",
        "x-content-type": edit:get-annotation-type($annotation)
    }
};

(:~
 : Returns the body's value for an annotation.
 : 
 : @see https://www.w3.org/TR/annotation-model/#embedded-textual-body
 : 
 : @param $annotation The node which serves as a basis for the annotation
 : @return The value of the annotation.
 :)
declare function edit:get-body-value($annotation as node())
as xs:string {
    let $value :=
        typeswitch ( $annotation )
        case element(tei:persName) return
            $annotation/string()

        case element(tei:placeName) return
            $annotation/string()
            
        case element(tei:add) return
            "an addition, place: " || $annotation/@place || ". text: " || $annotation || "."
            
        case element(tei:del) return
            "text deleted by the scribe: " || $annotation
            
        case element(tei:damage) return
            if ($annotation/tei:choice/tei:orig and $annotation/tei:choice/tei:supplied) then
                "a damaged passage. original: " || $annotation/tei:orig || ", supplied text: " || $annotation/tei:supplied
            else if ($annotation/tei:choice/tei:orig and $annotation/tei:choice/tei:corr) then
                "a damaged passage. original: " || $annotation/tei:orig || ", corrected text: " || $annotation/tei:corr
            else if ($annotation/text()[matches(., "[\w]")]) then
                "a damaged passage. legible text: " || $annotation
            else if ($annotation/tei:g) then
                if ($annotation/tei:g[@type = "quotation-mark"]) then
                    "a damaged passage. legible text: quotation mark"
                else
                    ()
            else
                let $text := string-join($annotation/descendant::text(), " ")
                return
                    "a damaged passage. legible text: " || $text
                    
        case element(tei:choice) return
            if($annotation/tei:sic) then
                let $resp :=
                    if ($annotation/tei:corr/@resp) then
                        "by the editors"
                    else
                        "by the scribe"
                return
                    "correction of faulty text. original: " || $annotation/tei:sic || 
                    ", corrected " || $resp || " to: " || $annotation/tei:corr 
            else
                "an abbreviation. original: " || $annotation/tei:abbr || ", expanded text: " || $annotation/tei:expan 
                
        case element(tei:unclear) return
            if ($annotation/@reason) then
                "a passage where the writing cannot be fully deciphered. text: " || $annotation || ", reason: " || replace($annotation/@reason, "_", " ")
            else
                "a passage where the writing cannot be fully deciphered. text: " || $annotation
        
        case element(tei:cit) return
            if ($annotation/@type = 'verbatim') then
                $annotation || ": a quote of " || $annotation/tei:bibl
            else
                let $references-strings :=
                    for $bibl in $annotation/tei:bibl return
                        "a reference to " || $bibl || ". original phrase: " || $bibl/preceding-sibling::tei:note[1]
                return        
                    $annotation || ": " || string-join($references-strings, "; ")
        
        case element(tei:surplus) return
            $annotation || ": surplus text"
        default return
            ()

        return
            normalize-space($value)
};


(:~
 : Returns the type of an annotation.
 : 
 : @see https://www.w3.org/TR/annotation-model/#string-body
 : 
 : @param $annotation The node which serves as a basis for the annotation
 : @return The content of bodyValue.
 :)
declare function edit:get-annotation-type($annotation as node())
as xs:string {
    switch ($annotation/local-name())
        case "persName" return "Person"
        case "placeName" return "Place"
        case "cit" return "Reference"
        default return "Editorial Comment"
};


(:~
 : Returns the target segment for an annotation.
 : 
 : @param $annotation The node which serves as a basis for the annotation
 : @param $documentURI The resource's URI to which the $annotation belongs to
 : @param $id The node ID of the annotation. It is equivalent to generate-id($annotation)
 : @return A map containing the target information
 :)
declare function edit:get-target-information($annotation as node(),
    $documentURI as xs:string,
    $id as xs:string)
as map(*) {
    map {
        "id": $commons:anno-ns || "/" || $documentURI || "/"|| $id,
        "format": "text/xml",
        "language": $annotation/ancestor-or-self::*[@xml:lang][1]/@xml:lang/string()
    }
};
