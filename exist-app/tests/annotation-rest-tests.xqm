xquery version "3.1";

module namespace art="http://ahikar.sub.uni-goettingen.de/ns/annotations/rest/tests";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace anno-rest="http://ahikar.sub.uni-goettingen.de/ns/annotations/rest" at "../modules/AnnotationAPI/annotations-rest.xqm";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";


declare
    %test:assertXPath("$result//@status = '404'")
    %test:assertXPath("$result//@message = 'One of the following requested resources couldn''t be found: qwerty, sample_teixml'")
function art:get-404-header()
as element() {
    let $resources := ("qwerty", "sample_teixml")
    return
       anno-rest:get-404-header($resources)
};

declare
    %test:assertTrue
function art:is-collection-annotationCollection-endpoint-http200()
as xs:boolean {
    let $url := $tc:server || "/annotations/ahikar/syriac/annotationCollection.json"
    return
        tc:is-endpoint-http200($url)
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'total')")
    %test:assertXPath("map:contains($result, 'first')")
    %test:assertXPath("map:contains($result, 'label')")
    %test:assertXPath("map:contains($result, 'last')")
    %test:assertXPath("map:contains($result, 'x-creator')")
    %test:assertXPath("map:contains($result, 'type')")
    %test:assertXPath("map:contains($result, 'id')")
function art:endpoint-collection-annotationCollection()
as item() {
    let $url := $tc:server || "/annotations/ahikar/syriac/annotationCollection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return 
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
        => map:get("annotationCollection")
};

declare
    %test:assertTrue
function art:is-document-annotationPage-endpoint-http200()
as xs:boolean {
    let $url := $tc:server || "/annotations/ahikar/arabic-karshuni/sample_edition/annotationPage.json"
    return
        tc:is-endpoint-http200($url)
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'partOf')")
    %test:assertXPath("map:contains($result, 'items')")
    %test:assertXPath("map:contains($result, 'startIndex')")
    %test:assertXPath("map:contains($result, 'prev')")
    %test:assertXPath("map:contains($result, 'next')")
    %test:assertXPath("map:contains($result, 'id')")
function art:endpoint-document-annotationPage()
as item() {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/annotationPage.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return 
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
        => map:get("annotationPage")
};
declare
    %test:assertTrue
function art:is-document-annotationCollection-endpoint-http200()
as xs:boolean {
    let $url := $tc:server || "/annotations/ahikar/arabic-karshuni/sample_edition_karshuni/annotationCollection.json"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'total')")
    %test:assertXPath("map:contains($result, 'first')")
    %test:assertXPath("map:contains($result, 'label')")
    %test:assertXPath("map:contains($result, 'last')")
    %test:assertXPath("map:contains($result, 'x-creator')")
    %test:assertXPath("map:contains($result, 'type')")
    %test:assertXPath("map:contains($result, 'id')")
function art:endpoint-document-annotationCollection()
as item() {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/annotationCollection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return 
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
        => map:get("annotationCollection")
};

declare
    %test:assertTrue
function art:is-item-annotationCollection-endpoint-http200()
as xs:boolean {
    let $url := $tc:server || "/annotations/ahikar/arabic-karshuni/sample_edition_arabic/83a/annotationCollection.json"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'total')")
    %test:assertXPath("map:contains($result, 'first')")
    %test:assertXPath("map:contains($result, 'label')")
    %test:assertXPath("map:contains($result, 'x-creator')")
    %test:assertXPath("map:contains($result, 'type')")
    %test:assertXPath("map:contains($result, 'id')")
function art:endpoint-item-annotationCollection()
as item() {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/83a/annotationCollection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return 
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
        => map:get("annotationCollection")
};

declare
    %test:assertTrue
function art:is-item-annotationPage-endpoint-http200()
as xs:boolean {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/83a/annotationPage.json"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'partOf')")
    %test:assertXPath("map:contains($result, 'items')")
    %test:assertXPath("map:contains($result, 'startIndex')")
    %test:assertXPath("map:contains($result, 'prev')")
    %test:assertXPath("map:contains($result, 'next')")
    %test:assertXPath("map:contains($result, 'id')")
function art:endpoint-item-annotationPage()
as item() {
    let $url := $tc:server || "/annotations/ahikar/syriac/sample_edition/83a/annotationPage.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return 
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
        => map:get("annotationPage")
};
