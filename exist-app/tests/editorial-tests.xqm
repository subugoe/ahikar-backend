xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace edit="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial" at "../modules/AnnotationAPI/editorial.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $t:sample-doc := doc($commons:data || "/sample_teixml.xml");

declare
    %test:assertEquals("ܐܬܘܪ")
function t:anno-get-body-value()
as xs:string {
    let $annotation := $t:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        edit:get-body-value($annotation)
};

declare
    %test:assertEquals("correction of faulty text. original: errror, corrected by the scribe to: error")
function t:anno-get-body-value-scribe()
as xs:string {
    let $annotation :=
        <choice xmlns="http://www.tei-c.org/ns/1.0">
            <sic>errror</sic>
            <corr>error</corr>
        </choice>
    return
        edit:get-body-value($annotation)
};

declare
    %test:assertEquals("correction of faulty text. original: errror, corrected by the editors to: error")
function t:anno-get-body-value-editor()
as xs:string {
    let $annotation :=
        <choice xmlns="http://www.tei-c.org/ns/1.0">
            <sic>errror</sic>
            <corr resp="#sb">error</corr>
        </choice>
    return
        edit:get-body-value($annotation)
};


declare
    %test:assertEquals("Person")
function t:get-annotation-type-person()
as xs:string {
    let $annotation := $t:sample-doc//tei:text[@type = "transcription"]/descendant::tei:persName[1]
    return
        edit:get-annotation-type($annotation)
};

declare
    %test:assertEquals("Place")
function t:get-annotation-type-place()
as xs:string {
    let $annotation := $t:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        edit:get-annotation-type($annotation)
};

declare
    %test:args("sample_teixml", "N1.2.3.4")
    %test:assertXPath("map:get($result, 'id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/sample_teixml/N1.2.3.4'")
    %test:assertXPath("map:get($result, 'format') = 'text/xml'")
    %test:assertXPath("map:get($result, 'language') = 'karshuni'")
function t:get-target-information($documentURI as xs:string,
    $id as xs:string)
as map() {
    let $annotation := $t:sample-doc//tei:text[@type = "transcription"]/descendant::tei:placeName[1]
    return
        edit:get-target-information($annotation, $documentURI, $id)
};

declare
    %test:args("sample_teixml", "83b") %test:assertXPath("count($result) = 80")
    %test:args("sample_syriac_teixml", "86r") %test:assertXPath("count($result) = 9")
function t:get-annotations($teixml-uri as xs:string,
    $page as xs:string)
as map()+ {
    let $pages := commons:get-page-fragments($teixml-uri, $page)
    return
        edit:get-annotations($pages, $teixml-uri)
};

declare
    %test:args("sample_teixml", "84a")
    %test:assertXPath("map:get($result, 'value') = 'ܢܕܢ܂'")
function t:get-annotations-detailed-body($teixml-uri as xs:string,
    $page as xs:string)
as map() {
    let $pages := commons:get-page-fragments($teixml-uri, $page)
    let $result-map := edit:get-annotations($pages, $teixml-uri)[1]
    let $bodyValue := map:get($result-map, "body")
    return
        $bodyValue
};

declare
    %test:args("sample_teixml", "84a")
    %test:assertXPath("$result = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/sample_teixml/annotation-N1.4.2.4.4.205.2'")
function t:get-annotations-detailed-id($teixml-uri as xs:string,
    $page as xs:string)
as xs:string {
    let $pages := commons:get-page-fragments($teixml-uri, $page)
    let $result-map := edit:get-annotations($pages, $teixml-uri)[1]
    let $id := map:get($result-map, "id")
    return
        $id
};

declare
    %test:args("sample_teixml", "84a")
    %test:assertXPath("$result instance of map()")
function t:get-annotations-detailed-target($teixml-uri as xs:string,
    $page as xs:string)
as map() {
    let $pages := commons:get-page-fragments($teixml-uri, $page)
    let $result-map := edit:get-annotations($pages, $teixml-uri)[1]
    let $target := map:get($result-map, "target")
    return
        $target
};
