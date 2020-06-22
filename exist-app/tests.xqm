xquery version "3.1";

(:~
 : Test module for the RESTXQ endpoints of the Ahikar TextAPI.
 : 
 : @author Michelle Weidling
 : @version 0.1.0
 :)

module namespace tests="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi" at "modules/tapi.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $tests:restxq := "http://0.0.0.0:8080/exist/restxq/";


(:~
 : One test to fail just to check for the test engine to recognize failing tests.
 :)
declare
    %test:assertTrue
function tests:fail() as xs:boolean {
    false()
};


(: creating sample data for testing ... :)
declare
    %test:setUp
function tests:_test-setup() as xs:string+ {
    xmldb:create-collection("/db", "test-records"),
    xmldb:store("/db/test-records", "white-spaces.xml", <record><id>12     34 56
    78</id></record>),
    xmldb:store("/db/test-records", "sample-tei.xml", <text xmlns="http://www.tei-c.org/ns/1.0" type="transcription">test      
        <note>test2</note>
        test3
        <sic>text4</sic>
    </text>),
    tapi:zip-text()
};


(: ... and removing it after all tests have been executed. :)
declare
    %test:tearDown
function tests:_test-teardown() as item() {
    xmldb:remove("/db/test-records")
};

(: *****************
 : * API ENDPOINTS * 
 : *****************
 :)

(: API information :)
declare
    (: check if requests work :)
    %test:assertXPath("map:get($result, 'request') => map:get('scheme') = 'http'")
    (: check if expathpkg works :)
    %test:assertXPath("map:get($result, 'package') => map:get('title') = 'TextAPI for Ahikar'")
    (: check if repo.xml works :)
    %test:assertXPath("map:get($result, 'meta') => map:get('target') = 'ahikar'")
function tests:api-info()  as item() {
    let $url := $tests:restxq || "api/info"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'title')")
    %test:assertXPath("map:contains($result, 'collector')")
    %test:assertXPath("map:contains($result, 'description')")
    %test:assertXPath("map:contains($result, 'sequence')")
function tests:collection-rest()  as item() {
    let $url := $tests:restxq || "/textapi/ahikar/ahiqar_collection/collection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'textapi')")
    %test:assertXPath("map:contains($result, 'label')")
    %test:assertXPath("map:contains($result, 'license')")
    %test:assertXPath("map:contains($result, 'sequence')")
function tests:manifest-rest() as item() {
    let $url := $tests:restxq || "/textapi/ahikar/ahiqar_collection/ahiqar_sample/manifest.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'textapi')")
    %test:assertXPath("map:contains($result, 'title')")
    %test:assertXPath("map:contains($result, 'type')")
    %test:assertXPath("map:contains($result, 'n')")
    %test:assertXPath("map:contains($result, 'content')")
    %test:assertXPath("map:contains($result, 'content-type')")
    %test:assertXPath("map:contains($result, 'lang')")
    %test:assertXPath("map:contains($result, 'image')")
function tests:item-rest() as item() {
    let $url := $tests:restxq || "/textapi/ahikar/ahiqar_collection/ahiqar_agg-82a/latest/item.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};


declare
    (: check if tei:div is present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("$result//*[@class = 'tei_body']")
function tests:content-rest() as document-node() {
    let $url := $tests:restxq || "/content/ahiqar_sample-82a.html"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2]
};


declare
    (: check if ZIP is present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertExists
function tests:content-zip() as xs:base64Binary {
    let $url := $tests:restxq || "/content/ahikar-plain-text.zip"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2]
};


declare
    (: check if txt is present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("matches($result, '[\w]')")
function tests:content-txt() as xs:string {
    let $url := $tests:restxq || "/textapi/ahikar/ahiqar_collection/ahiqar_sample.txt"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2]
};


(: ************************
 : * UNDERLYING FUNCTIONS *
 : ************************
 : all the functions that contribute to but do not define RESTXQ endpoints
 :)

declare
    %test:args("ahiqar_collection", "http://localhost:8080/exist/restxq")
    (: tests if the object is created at all :)
    %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Story and Proverbs of Ahikar the Wise' ")
    (: tests if the sequence construction works properly :)
    %test:assertXPath("$result//*/string() = 'http://localhost:8080/exist/restxq/api/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json' ")
function tests:collection($collection as xs:string, $server as xs:string) as item()+ {
    tapi:collection($collection, $server)
};


declare
    %test:args("ahiqar_collection", "ahiqar_agg", "http://localhost:8080/exist/restxq")
    (: tests if the object is created at all :)
    %test:assertXPath("$result//*[local-name(.) = 'label'] = 'Beispieldatei zum Testen' ")
    (: tests if the sequence construction works properly :)
    %test:assertXPath("$result//*[local-name(.) = 'id'] = 'http://localhost:8080/exist/restxq/api/textapi/ahikar/ahiqar_collection/ahiqar_agg-82a/latest/item.json' ")
function tests:manifest($collection as xs:string, $document as xs:string, 
$server as xs:string) as element(object) {
    tapi:manifest($collection, $document, $server)
};



declare
    %test:args("ahiqar_agg", "82a", "http://localhost:8080/exist/restxq")
    (: checks if the correct file has been opened :)
    %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh' ")
    (: checks if language assembling works correctly :)
    %test:assertXPath("$result//*[local-name(.) = 'lang'] = 'Classical Syriac' ")
    (: checks if underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'content'] = 'http://localhost:8080/exist/restxq/api/content/ahiqar_sample-82a.html' ")
    (: checks if images connected to underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'id'] = 'http://localhost:8080/exist/restxq/api/images/3r1nz' ")
function tests:item($document as xs:string, $page as xs:string, $server as xs:string) 
as element(object){
    tapi:item($document, $page, $server)
};


declare
    %test:args("ahiqar_sample", "82a")
    (: checks if there is text at all in the result :)
    %test:assertXPath("$result//text()[matches(., '[\w]')]")
    (: if a div[@class = 'tei_body'] is present, the transformation has been successfull :)
    %test:assertXPath("$result//*[@class = 'tei_body']")
    (: this is some text on 82a (and thus should be part of the result) :)
    %test:assertXPath("$result//* = 'ܘܬܥܐܠܝ ܕܟܪܗ ܐܠܝ ܐܠܐܒܕ. ܘܢܟܬܒ ܟܒܪ'") 
    (: this is some text on 83a which shouldn't be part of the result :)
    %test:assertXPath("not($result//* = 'ܡܢ ܐܠܣܡܐ ܩܐܝܠܐ. ܒܚܝܬ ܐܬܟܠܬ ܐܘܠܐ ܥܠܝ ܐܠܐܨܢܐܡ' )")
function tests:html-creation($document as xs:string, $page as xs:string) as element(div) {
    tapi:content($document, $page)
};


(: this test has to be executed before tapi:compress-to-zip because it creates
 : the /txt/ collection and its contents for the zipping. :)
declare
    %test:assertExists
function tests:zip-text() as item()+ {
    tapi:zip-text()
};


declare
    %test:assertExists
function tests:compress-text() as xs:base64Binary {
    tapi:compress-to-zip()
};


declare
    %test:assertEquals("test test3 ")
function tests:plain-text() as xs:string {
    let $tei := doc("/db/test-records/sample-tei.xml")/*
    return
        tapi:create-plain-text($tei)
};


declare
    %test:args("ahiqar_sample")
    %test:assertEquals("text/xml")
function tests:tgmd-format($uri as xs:string) as xs:string {
    tapi:get-format($uri)
};


declare
    %test:args("ahiqar_sample", "transcription")
    %test:assertXPath("$result[local-name(.) = 'text' and @type = 'transcription']")
function tests:get-tei($document as xs:string, $type as xs:string) as element() {
    tapi:get-TEI-text($document, $type)
};


declare
    %test:assertXPath("$result/string() = '1234 5678'")
function tests:remove-whitespaces() as document-node() {
    let $doc := doc("/db/test-records/white-spaces.xml")
    return
        tapi:remove-whitespaces($doc)
};