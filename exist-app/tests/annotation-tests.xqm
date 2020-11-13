xquery version "3.1";

module namespace at="http://ahikar.sub.uni-goettingen.de/ns/annotations/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "../modules/annotations.xqm";

declare variable $at:sample-doc := doc($commons:data || "/ahiqar_sample.xml");

declare
    %test:args("ahiqar_sample") %test:assertTrue
    %test:args("ahiqar_agg") %test:assertFalse
function at:is-resource-xml($uri as xs:string)
as xs:boolean {
    anno:is-resource-xml($uri)
};

declare
    %test:args("ahiqar_sample") %test:assertFalse
    %test:args("ahiqar_agg") %test:assertTrue
    %test:pending
function at:is-resource-edition($uri as xs:string)
as xs:boolean {
    anno:is-resource-edition($uri)
};

declare
    %test:args("ahiqar_sample") %test:assertXPath("count($result) = 4")
    %test:args("ahiqar_sample") %test:assertXPath("$result = '82a'")
function at:get-pages-in-TEI($uri as xs:string)
as xs:string+ {
    anno:get-pages-in-TEI($uri)
};

declare
    %test:assertTrue
function at:are-resources-available-true()
as xs:boolean {
    let $resources := "ahiqar_sample"
    return
        anno:are-resources-available($resources)
};

declare
    %test:assertFalse
function at:are-resources-available-false()
as xs:boolean {
    let $resources := ("qwerty", "ahiqar_sample")
    return
        anno:are-resources-available($resources)
};

declare
    %test:assertXPath("$result//@status = '404'")
    %test:assertXPath("$result//@message = 'One of the following requested resources couldn''t be found: qwerty, ahiqar_sample'")
function at:get-404-header()
as element() {
    let $resources := ("qwerty", "ahiqar_sample")
    return
       anno:get-404-header($resources)
};


declare
    %test:args("ahiqar_sample") %test:assertEquals("ahiqar_agg")
    %test:args("ahiqar_agg") %test:assertEquals("ahiqar_collection")
    %test:args("ahiqar_collection") %test:assertEmpty
function at:get-parent-aggregation($uri as xs:string)
as xs:string? {
    anno:get-parent-aggregation($uri)
};

declare
    %test:args("ahiqar_sample", "82a", "next") %test:assertEquals("82b")
    %test:args("ahiqar_sample", "82b", "prev") %test:assertEquals("82a")
    %test:args("ahiqar_sample", "83b", "next") %test:assertEmpty
    %test:args("ahiqar_sample", "82a", "prev") %test:assertEmpty
    %test:pending
function at:get-prev-or-next-page($documentURI as xs:string,
    $page as xs:string, 
    $type as xs:string)
as xs:string? {
    anno:get-prev-or-next-page($documentURI, $page, $type)
};

declare
    %test:args("ahiqar_sample") %test:assertEquals("Beispieldatei zum Testen")
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
    %test:args("ahiqar_sample", "N1.2.3.4")
    %test:assertXPath("map:get($result, 'id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/ahiqar_sample/N1.2.3.4'")
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
    %test:args("ahiqar_collection", "ahiqar_agg", "82a", "http://localhost:8080")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/annotationCollection/ahiqar_agg/82a'")
    %test:assertXPath("map:get($result, 'annotationCollection') => map:get('label') = 'Ahikar annotations for textgrid:ahiqar_agg: Beispieldatei zum Testen, page 82a'")
    %test:pending
function at:make-annotationCollection-for-manifest($collection as xs:string,
    $document as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    anno:make-annotationCollection-for-manifest($collection, $document, $page, $server)
};

(:declare:)
(:    %test:args("3r679", "114r"):)
(:    %test:assertEquals("0"):)
(:function at:anno-determine-start-index-for-page($uri as xs:string, $page as xs:string) {:)
(:    anno:determine-start-index-for-page($uri, $page):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("16"):)
(:function at:anno-determine-start-index($uri as xs:string) {:)
(:    anno:determine-start-index($uri):)
(:};:)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("3r679"):)
(:function at:anno-get-parent-aggregation($uri as xs:string) {:)
(:    anno:get-parent-aggregation($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("114r", "114v"):)
(:function at:anno-get-pages-in-TEI($uri as xs:string) {:)
(:    anno:get-pages-in-TEI($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertTrue:)
(:function at:anno-is-resource-edition($uri as xs:string) {:)
(:    anno:is-resource-edition($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertTrue:)
(:function at:anno-is-resource-xml($uri as xs:string) {:)
(:    anno:is-resource-xml($uri):)
(:};:)


(::)
(:declare:)
(:    %test:args("asdf"):)
(:    %test:assertFalse:)
(:(:    %test:args("3r131"):):)
(:(:    %test:assertTrue:):)
(:function at:anno-are-resources-available($resources as xs:string+) {:)
(:    anno:are-resources-available($resources):)
(:};:)


(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("Simon Birol, Aly Elrefaei"):)
(:function at:anno-get-creator($uri as xs:string) {:)
(:    anno:get-creator($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("Brit. Lib. Add. 7200"):)
(:function at:anno-get-metadata-title($uri as xs:string) {:)
(:    anno:get-metadata-title($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertEquals("3r676", "3r672"):)
(:function at:anno-get-prev-xml-uris($uri as xs:string) {:)
(:    anno:get-prev-xml-uris($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertEquals("3r676", "3r672"):)
(:function at:anno-get-xmls-prev-in-collection($uri as xs:string) {:)
(:    anno:get-xmls-prev-in-collection($uri):)
(:};:)


(:declare:)
(:    %test:args("3r679", "114r", "next"):)
(:    %test:assertEquals("114v"):)
(:function at:anno-get-prev-or-next-page($documentURI as xs:string,:)
(:$page as xs:string, $type as xs:string) {:)
(:    anno:get-prev-or-next-page($documentURI, $page, $type):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r9ps"):)
(:    %test:assertEquals("3r177", "3r178", "3r7vw", "3r7p1", "3r7p9", "3r7sk", "3r7tp", "3r7vd", "3r179", "3r7n0", "3r9vn", "3r9wf", "3rb3z", "3rbm9", "3rbmc", "3rx14", "3vp38"):)
(:function at:anno-get-uris($documentURI) {:)
(:    anno:get-uris($documentURI):)
(:};:)
