xquery version "3.1";

module namespace at="http://ahikar.sub.uni-goettingen.de/ns/annotations/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "../modules/annotations.xqm";

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
    %test:assertFalse
function at:are-resources-available-false()
as xs:boolean {
    let $resources := ("qwerty", "sample_teixml")
    return
        anno:are-resources-available($resources)
};

declare
    %test:assertXPath("$result//@status = '404'")
    %test:assertXPath("$result//@message = 'One of the following requested resources couldn''t be found: qwerty, sample_teixml'")
function at:get-404-header()
as element() {
    let $resources := ("qwerty", "sample_teixml")
    return
       anno:get-404-header($resources)
};


declare
    %test:args("sample_teixml") %test:assertEquals("sample_edition")
    %test:args("sample_edition") %test:assertEquals("sample_lang_aggregation")
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
function at:anno-get-bodyValue() {
    let $annotation := $at:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        anno:get-bodyValue($annotation)
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
    %test:args("sample_lang_aggregation", "sample_edition", "82a", "http://localhost:8080")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationCollection/sample_edition/82a'")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('type') = 'AnnotationCollection'")
function at:make-annotationCollection-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    anno:make-annotationCollection-for-manifest($collection, $document, $page, $server)
};

declare
    %test:args("sample_teixml", "82a") %test:assertXPath("$result//* = 'حقًا'")
function at:get-page-fragment($documentURI as xs:string,
    $page as xs:string)
as element(tei:TEI) {
    anno:get-page-fragment($documentURI, $page)
};

declare
    %test:args("sample_main_edition") %test:assertEquals("66")
    %test:args("sample_lang_aggregation") %test:assertEquals("66")
function at:get-total-no-of-annotations($uri as xs:string) {
    anno:get-total-no-of-annotations($uri)
};

declare
    %test:assertEquals("sample_teixml")
function at:get-all-xml-uris-for-submap()
as xs:string* {
    let $map :=
         map {
            "sample_lang_aggregation":
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
                "sample_lang_aggregation":
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
    %test:assertEquals("http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation/sample_edition/11/annotationPage.json")
    %test:args("sample_edition", "")
    %test:assertEquals("http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation/sample_edition/annotationPage.json")
    %test:args("", "")
    %test:assertEmpty
function at:get-prev-or-next-annotationPage-url($document as xs:string?,
    $page as xs:string?)
as xs:string? {
    let $collection := "sample_lang_aggregation"
    let $server := "http://localhost:8080"
    return
        anno:get-prev-or-next-annotationPage-url($collection, $document, $page, $server)
};

declare
    %test:args("sample_edition") %test:assertTrue
    %test:args("sample_lang_aggregation") %test:assertFalse
function at:is-resource-edition($uri as xs:string) {
    let $map := 
        map {
                "sample_lang_aggregation":
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
function at:get-creator($uri as xs:string)
as xs:string {
    anno:get-creator($uri)
};

declare
    %test:args("sample_edition", 
        "Beispieledition", 
        "http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation/sample_edition/82a/annotationPage.json", 
        "http://localhost:8080/api/annotations/ahikar/sample_lang_aggregation/sample_edition/83b/annotationPage.json")
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
    %test:args("sample_lang_aggregation", "sample_edition", "http://localhost:8080")
    %test:assertXPath("map:get($result, 'annotationPage') => map:get('id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationPage/sample_lang_aggregation/sample_edition'")
function at:make-annotationPage($collection as xs:string, 
    $manifest as xs:string,
    $server as xs:string)
as map() {
    anno:make-annotationPage($collection, $manifest, $server)
};

declare
    %test:args("sample_teixml", "83b") %test:assertXPath("count($result) = 15")
function at:get-annotations($teixml-uri as xs:string,
    $page as xs:string)
as map()+ {
    anno:get-annotations($teixml-uri, $page)
};
