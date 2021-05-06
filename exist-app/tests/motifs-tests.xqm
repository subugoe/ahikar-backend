xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace motifs="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs" at "../modules/AnnotationAPI/motifs.xqm";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $t:sample-doc := doc($commons:data || "/sample_teixml.xml");


declare
    %test:assertEquals("1")
function t:get-motifs()
as xs:integer {
    let $teixml-uri := "sample_teixml"
    let $page := "82a"
    let $pages := commons:get-page-fragments($teixml-uri, $page)
    return
        motifs:get-motifs($pages, $teixml-uri)
        => count()
};

declare
    %test:assertEquals("1")
function t:get-all-motifs-in-document()
as xs:integer {
    let $teixml-uri := "sample_teixml"
    let $xml-doc := commons:open-tei-xml($teixml-uri)
    return
        motifs:get-all-motifs-in-document($xml-doc, $teixml-uri)
        => count()
};

declare
    %test:assertTrue
function t:is-annotationPage-endpoint-http200()
as xs:boolean {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/82a/annotationPage.json"
    return
        tc:is-endpoint-http200($url)
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:get($result, 'x-content-type') = 'Motif'")
    %test:assertXPath("map:get($result, 'value') = 'Successful courtier'")
    %test:assertXPath("map:get($result, 'format') = 'text/plain'")
    %test:assertXPath("map:get($result, 'type') = 'TextualBody'")
function t:does-annotationPage-have-motifs()
as item() {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/82a/annotationPage.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    let $items := 
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
        => map:get("annotationPage")
        => map:get("items")
    return
        $items?(array:size($items))
        => map:get("body")
};

declare
    %test:assertEquals("Parable (plants)")
function t:get-body-value()
as xs:string {
    let $motif := processing-instruction oxy_comment_start {'comment="parable_plants"'}
    return
        motifs:get-body-value($motif)
};

declare
    %test:assertXPath("map:get($result, 'format') = 'text/plain'")
    %test:assertXPath("map:get($result, 'type') = 'TextualBody'")
    %test:assertXPath("map:get($result, 'value') = 'Parable (plants)'")
    %test:assertXPath("map:get($result, 'x-content-type') = 'Motif'")
function t:get-body-object()
as map(*) {
    let $motif := processing-instruction oxy_comment_start {'comment="parable_plants"'}
    return
        motifs:get-body-object($motif)
};

declare
    %test:assertXPath("map:get($result, 'format') = 'text/xml'")
    %test:assertXPath("map:get($result, 'id') = 'http://ahikar.sub.uni-goettingen.de/ns/annotations/sample_teixml/N4.4.2.4.4.10.4'")
    %test:assertXPath("map:get($result, 'language') = 'karshuni'")
function t:get-target-information()
as map(*) {
    let $teixml-uri := "sample_teixml"
    let $doc := commons:open-tei-xml($teixml-uri)
    let $motif := $doc//processing-instruction('oxy_comment_start')[1]
    return
        motifs:get-target-information($teixml-uri, $motif)
};
