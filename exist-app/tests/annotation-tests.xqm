xquery version "3.1";

module namespace at="http://ahikar.sub.uni-goettingen.de/ns/annotations/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "../modules/AnnotationAPI/annotations.xqm";

declare variable $at:sample-doc := doc($commons:data || "/sample_teixml.xml");

declare
    %test:args("sample_teixml") %test:assertTrue
    %test:args("sample_edition") %test:assertFalse
function at:is-resource-xml($uri as xs:string)
as xs:boolean {
    anno:is-resource-xml($uri)
};

declare
    %test:args("sample_teixml") %test:assertXPath("count($result) = 5")
    %test:args("sample_teixml") %test:assertXPath("$result = '82a'")
function at:get-pages-in-TEI($uri as xs:string)
as xs:string+ {
    anno:get-pages-in-TEI($uri)
};

declare
    %test:assertTrue
function at:are-resources-available-true()
as xs:boolean {
    let $resources := "sample_teixml"
    return
        anno:are-resources-available($resources)
};

declare
    %test:assertTrue
function at:are-resources-available-lang-collection-true()
as xs:boolean {
    let $resources := "syriac"
    return
        anno:are-resources-available($resources)
};

declare
    %test:assertFalse
function at:are-resources-available-false()
as xs:boolean {
    let $resources := ("qwerty", "sample_teixml")
    return
        anno:are-resources-available($resources)
};

declare
    %test:args("sample_teixml") %test:assertEquals("sample_edition")
    %test:args("sample_edition") %test:assertEquals("sample_lang_aggregation_syriac")
    %test:args("sample_main_edition") %test:assertEmpty
function at:get-parent-aggregation($uri as xs:string)
as xs:string? {
    anno:get-parent-aggregation($uri)
};

declare
    %test:args("sample_teixml", "82a", "next") %test:assertEquals("82b")
    %test:args("sample_teixml", "82b", "prev") %test:assertEquals("82a")
    %test:args("sample_teixml", "83b", "next") %test:assertEmpty
    %test:args("sample_teixml", "82a", "prev") %test:assertEmpty
    %test:pending
function at:get-prev-or-next-page($documentURI as xs:string,
    $page as xs:string, 
    $type as xs:string)
as xs:string? {
    anno:get-prev-or-next-page($documentURI, $page, $type)
};

declare
    %test:args("sample_teixml") %test:assertEquals("Beispieldatei zum Testen")
function at:get-metadata-title($uri as xs:string)
as xs:string {
    anno:get-metadata-title($uri)
};

declare
    %test:assertEquals("A place's name.")
function at:anno-get-body-value()
as xs:string {
    let $annotation := $at:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        anno:get-body-value($annotation)
};

declare
    %test:assertEquals("Person")
function at:get-annotation-type-person()
as xs:string {
    let $annotation := $at:sample-doc//tei:text[@type = "transcription"]/descendant::tei:persName[1]
    return
        anno:get-annotation-type($annotation)
};

declare
    %test:assertEquals("Place")
function at:get-annotation-type-place()
as xs:string {
    let $annotation := $at:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        anno:get-annotation-type($annotation)
};

declare
    %test:args("sample_teixml", "N1.2.3.4")
    %test:assertXPath("map:get($result, 'id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/sample_teixml/N1.2.3.4'")
    %test:assertXPath("map:get($result, 'format') = 'text/xml'")
    %test:assertXPath("map:get($result, 'language') = 'karshuni'")
function at:get-target-information($documentURI as xs:string,
    $id as xs:string)
as map() {
    let $annotation := $at:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        anno:get-target-information($annotation, $documentURI, $id)
};

declare
    %test:args("syriac", "sample_edition", "82a", "http://localhost:8080")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationCollection/sample_edition/82a'")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('type') = 'AnnotationCollection'")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('label') = 'Ahikar annotations for textgrid:sample_edition: Beispieldatei zum Testen, page 82a'")
function at:make-annotationCollection-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    anno:make-annotationCollection-for-manifest($collection, $document, $page, $server)
};

declare
    %test:args("sample_teixml", "82a", "transcription") %test:assertXPath("$result//* = 'حقًا'")
    %test:args("sample_teixml", "82a", "transliteration") %test:assertXPath("$result//* = 'الحاسوب'")
function at:get-page-fragment($documentURI as xs:string,
    $page as xs:string,
    $text-type as xs:string)
as element(tei:TEI) {
    anno:get-page-fragment($documentURI, $page, $text-type)
};

declare
    %test:args("sample_main_edition") %test:assertEquals("476")
    %test:args("syriac") %test:assertEquals("185")
    %test:args("arabic-karshuni") %test:assertEquals("291")
function at:get-total-no-of-annotations($uri as xs:string) {
    anno:get-total-no-of-annotations($uri)
};

declare
    %test:assertEquals("sample_teixml")
function at:get-all-xml-uris-for-submap()
as xs:string* {
    let $map :=
         map {
            "sample_lang_aggregation_syriac":
            map {
                "sample_edition": "sample_teixml",
                "faux_edition": "faux_teixml"
            }
         }
    return
        anno:get-all-xml-uris-for-submap($map)
};


declare
    %test:args("sample_edition") %test:assertEquals("sample_teixml")
function at:find-in-map($key as xs:string)
as item()? {
    let $map :=
        map {
                "sample_lang_aggregation_syriac":
                map {
                    "sample_edition": "sample_teixml",
                    "faux_edition": "faux_teixml"
                }
             }  
    
    return
        anno:find-in-map($map, $key)
};


declare
    %test:args("sample_edition", "11")
    %test:assertEquals("http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation_syriac/sample_edition/11/annotationPage.json")
    %test:args("sample_edition", "")
    %test:assertEquals("http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation_syriac/sample_edition/annotationPage.json")
    %test:args("", "")
    %test:assertEmpty
function at:get-prev-or-next-annotationPage-url($document as xs:string?,
    $page as xs:string?)
as xs:string? {
    let $collection := "sample_lang_aggregation_syriac"
    let $server := "http://localhost:8080"
    return
        anno:get-prev-or-next-annotationPage-url($collection, $document, $page, $server)
};

declare
    %test:args("sample_edition") %test:assertTrue
    %test:args("sample_lang_aggregation_syriac") %test:assertFalse
function at:is-resource-edition($uri as xs:string) {
    let $map := 
        map {
                "sample_lang_aggregation_syriac":
                map {
                    "sample_edition": "sample_teixml",
                    "faux_edition": "faux_teixml"
                }
             }  
    return
        anno:is-resource-edition($map, $uri)
};

declare
    %test:args("sample_edition", "82a", "next") %test:assertEquals("82b")
    %test:args("sample_edition", "82a", "prev") %test:assertEmpty
    %test:args("sample_edition", "82b", "prev") %test:assertEquals("82a")
function at:get-prev-or-next-page($manifest-uri as xs:string,
    $page as xs:string, 
    $type as xs:string)
as xs:string? {
    anno:get-prev-or-next-page($manifest-uri, $page, $type)
};

declare
    %test:args("sample_teixml") %test:assertEquals("Simon Birol, Aly Elrefaei")
    %test:args("sample_edition") %test:assertEquals("Simon Birol, Aly Elrefaei")
    %test:args("syriac") %test:assertEquals("Simon Birol, Aly Elrefaei")
    %test:args("arabic-karshuni") %test:assertEquals("Simon Birol, Aly Elrefaei")
function at:get-creator($uri as xs:string)
as xs:string {
    anno:get-creator($uri)
};

declare
    %test:args("sample_edition", 
        "Beispieledition", 
        "http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation_syriac/sample_edition/82a/annotationPage.json", 
        "http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation_syriac/sample_edition/83b/annotationPage.json")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('label') = 'Ahikar annotations for textgrid:sample_edition: Beispieledition'")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('x-creator') = 'Simon Birol, Aly Elrefaei'")
function at:make-annotationCollection-map($uri as xs:string,
    $title as xs:string,
    $first-entry as xs:string,
    $last-entry as xs:string)
as map() {
    anno:make-annotationCollection-map($uri, $title, $first-entry, $last-entry)
};

declare
    %test:args("sample_lang_aggregation_syriac", "sample_edition", "http://localhost:8080")
    %test:assertXPath("map:get($result, 'annotationPage') => map:get('id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationPage/sample_lang_aggregation_syriac/sample_edition'")
    %test:pending
function at:make-annotationPage($collection as xs:string, 
    $manifest as xs:string,
    $server as xs:string)
as map() {
    anno:make-annotationPage($collection, $manifest, $server)
};

declare
    %test:args("sample_teixml", "83b") %test:assertXPath("count($result) = 80")
    %test:args("sample_syriac_teixml", "86r") %test:assertXPath("count($result) = 9")
function at:get-annotations($teixml-uri as xs:string,
    $page as xs:string)
as map()+ {
    anno:get-annotations($teixml-uri, $page)
};

declare
    %test:args("sample_teixml", "84a")
    %test:assertXPath("map:get($result, 'value') = 'A person''s name.'")
function at:get-annotations-detailed-body($teixml-uri as xs:string,
    $page as xs:string)
as map() {
    let $result-map := anno:get-annotations($teixml-uri, $page)[1]
    let $bodyValue := map:get($result-map, "body")
    return
        $bodyValue
};

declare
    %test:args("sample_teixml", "84a")
    %test:assertXPath("$result = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/sample_teixml/annotation-N1.2.1.2.3.100.3'")
function at:get-annotations-detailed-id($teixml-uri as xs:string,
    $page as xs:string)
as xs:string {
    let $result-map := anno:get-annotations($teixml-uri, $page)[1]
    let $id := map:get($result-map, "id")
    return
        $id
};

declare
    %test:args("sample_teixml", "84a")
    %test:assertXPath("$result instance of map()")
function at:get-annotations-detailed-target($teixml-uri as xs:string,
    $page as xs:string)
as map() {
    let $result-map := anno:get-annotations($teixml-uri, $page)[1]
    let $target := map:get($result-map, "target")
    return
        $target
};

declare
    %test:args("sample_edition", "82a") %test:assertEquals("0")
    %test:args("sample_edition", "82b") %test:assertEquals("22")
function at:determine-start-index-for-page($uri as xs:string,
    $page as xs:string)
as xs:integer {
    anno:determine-start-index-for-page($uri, $page)
};

declare
    %test:args("sample_lang_aggregation_syriac") %test:assertEquals("0")
    %test:args("sample_edition") %test:assertEquals("0")
    %test:args("sample_teixml") %test:assertEquals("0")
function at:determine-start-index($uri as xs:string)
as xs:integer {
    anno:determine-start-index($uri)
};


declare
    %test:args("next", "1r") %test:assertEquals("1v")
    %test:args("prev", "1r") %test:assertEmpty
    %test:args("next", "2r") %test:assertEmpty
    %test:args("prev", "2r") %test:assertEquals("1ab")
function at:get-prev-or-next($type as xs:string,
    $searched-for as xs:string)
as xs:string? {
    let $entities := ("1r", "1v", "1ab", "2r")
    return
        anno:get-prev-or-next($entities, $searched-for, $type)
};

declare
    %test:args("sample_lang_aggregation_syriac", "sample_edition", "next") %test:assertEmpty
    %test:args("sample_lang_aggregation_syriac", "sample_edition", "prev") %test:assertEmpty
function anno:get-prev-or-next-annotationPage-ID($collection as xs:string,
    $document as xs:string,
    $type as xs:string)
as xs:string? {
    anno:get-prev-or-next-annotationPage-ID($collection, $document, $type)
};

declare
    %test:args("sample_lang_aggregation_syriac", "sample_edition", "84a", "http://localhost:8080")
    %test:assertEquals("http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationPage/sample_lang_aggregation_syriac/sample_edition-84a")
function at:make-annotationPage-for-manifest-id($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as xs:string {
    let $result := anno:make-annotationPage-for-manifest($collection, $document, $page, $server)
    return
        map:get($result, "annotationPage")
        => map:get("id")
};


declare
    %test:args("sample_lang_aggregation_syriac", "sample_edition", "84a", "http://localhost:8080")
    %test:assertEquals("http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationCollection/sample_edition")
function at:make-annotationPage-for-manifest-part-of($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as xs:string {
    let $result := anno:make-annotationPage-for-manifest($collection, $document, $page, $server)
    return
        map:get($result, "annotationPage")
        => map:get("partOf")
        => map:get("id")
};

declare
    %test:args("syriac", "http://localhost:8080")
    %test:assertEquals("http://localhost:8080/api/annotations/ahikar/syriac/sample_edition/annotationPage.json")
function at:get-information-for-collection-object($collection-type as xs:string,
    $server as xs:string)
as xs:string {
    let $result := anno:get-information-for-collection-object($collection-type, $server)
    return
        map:get($result, "annotationCollection")
        => map:get("first")
};

declare
    %test:args("syriac", "sample_edition", "http://localhost:8080")
    %test:assertXPath("$result instance of map()")
    %test:args("syriac", "", "http://localhost:8080")
    %test:assertXPath("$result instance of map()")
function at:make-annotationCollection($collection as xs:string,
    $document as xs:string?,
    $server as xs:string)
as map() {
    anno:make-annotationCollection($collection, $document, $server)
};

declare
    %test:args("sample_teixml") %test:assertEmpty
function at:get-prev-xml-uris($uri as xs:string)
as xs:string* {
    anno:get-prev-xml-uris($uri)
};

declare
    %test:args("sample_teixml") %test:assertEmpty
    %test:args("sample_edition") %test:assertEmpty
function at:get-xmls-prev-in-collection($uri as xs:string)
as xs:string* {
    anno:get-xmls-prev-in-collection($uri)
};

declare
    %test:args("syriac") %test:assertEquals("sample_lang_aggregation_syriac")
    %test:args("arabic-karshuni") %test:assertXPath("count($result) = 2 and $result = 'sample_lang_aggregation_arabic' and $result = 'sample_lang_aggregation_karshuni'")
function at:get-lang-aggregation-uris($collection-type as xs:string)
as xs:string+ {
    anno:get-lang-aggregation-uris($collection-type)
};

declare
    %test:args("syriac") %test:assertEquals("The Syriac Collection")
    %test:args("arabic-karshuni") %test:assertEquals("The Arabic and Karshuni Collections")
    %test:args("sample_edition") %test:assertEquals("Beispieldatei zum Testen")
    %test:args("asdf") %test:assertError("COMMONS002")
function at:make-collection-object-title($collection-type as xs:string) {
    anno:make-collection-object-title($collection-type)
};

declare
    %test:args("syriac") %test:assertEquals("sample_lang_aggregation_syriac")
    %test:args("arabic-karshuni") %test:assertXPath("count($result) = 2 and $result = 'sample_lang_aggregation_arabic' and $result = 'sample_lang_aggregation_karshuni'")
    %test:args("sample_edition") %test:assertEquals("sample_edition")
function at:determine-uris-for-collection($collection as xs:string)
as xs:string+ {
    anno:determine-uris-for-collection($collection)
};
