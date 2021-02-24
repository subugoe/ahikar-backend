xquery version "3.1";

(:~
 : Test module for the RESTXQ endpoints of the Ahikar TextAPI.
 : 
 : @author Michelle Weidling
 : @version 0.1.0
 :)

module namespace tt="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi" at "../modules/tapi.xqm";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:setUp
function tt:_test-setup() as xs:string+ {
    xmldb:create-collection("/db", "test-records"),
    xmldb:store("/db/test-records", "white-spaces.xml", <record><id>12     34 56
    78</id></record>),
    xmldb:store("/db/test-records", "sample-tei.xml", <text xmlns="http://www.tei-c.org/ns/1.0" type="transcription">test      
        <note>test2</note>
        test3
        <sic>text4</sic>
        <placeName>Berlin</placeName>
    </text>),
    xmldb:store("/db/test-records", "origin-country-only.xml", <teiHeader xmlns="http://www.tei-c.org/ns/1.0">      
        <history>
            <origin>
                <country>Iraq</country>
            </origin>
        </history>
    </teiHeader>),
    xmldb:store("/db/test-records", "origin-place-only.xml", <teiHeader xmlns="http://www.tei-c.org/ns/1.0">      
        <history>
            <origin>
                <placeName>Alqosh</placeName>
            </origin>
        </history>
    </teiHeader>),
    xmldb:store("/db/test-records", "header-empty-history-msIdentifier.xml", <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
        <msIdentifier/>
        <history/>
    </teiHeader>),
    xmldb:store("/db/test-records", "location-country-only.xml", <teiHeader xmlns="http://www.tei-c.org/ns/1.0">      
        <msIdentifier>
            <settlement>
                <country>Great Britain</country>
            </settlement>
        </msIdentifier>
    </teiHeader>),
    xmldb:store("/db/test-records", "location-institution-only.xml", <teiHeader xmlns="http://www.tei-c.org/ns/1.0">  
        <msIdentifier>
            <institution>University of Cambridge - Cambridge University Library</institution>
        </msIdentifier>
    </teiHeader>)
};

declare
    %test:tearDown
function tt:_test-teardown() as item() {
    xmldb:remove("/db/test-records")
};

declare
    (: check if requests work :)
    %test:assertXPath("map:get($result, 'request') => map:get('scheme') = 'http'")
    (: check if expathpkg works :)
    %test:assertXPath("map:get($result, 'package') => map:get('title') = 'Ahiqar'")
    (: check if repo.xml works :)
    %test:assertXPath("map:get($result, 'meta') => map:get('target') = 'ahikar'")
function tt:api-info()  as item() {
    let $url := $tc:server || "/info"
    let $req := tc:make-request($url)
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};


declare
    %test:assertTrue
function tt:is-html-api-available()
as xs:boolean {
    let $url := $tc:server || "/content/sample_teixml-82a.html"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if tei:div is present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("$result//*[@class = 'tei_body']")
function tt:content-rest() as document-node() {
    let $url := $tc:server || "/content/sample_teixml-82a.html"
    let $req := tc:make-request($url)
    return http:send-request($req)[2]
};


declare
    (: check if ZIP is present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertExists
    %test:pending
function tt:content-zip() as xs:base64Binary {
    let $url := $tc:server || "/content/ahikar-plain-text.zip"
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
function tt:content-txt() as xs:string {
    let $url := $tc:server || "/textapi/ahikar/syriac/sample_teixml.txt"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2]
};


declare
    %test:assertTrue
function tt:is-txt-api-available()
as xs:boolean {
    let $url := $tc:server || "/content/sample_teixml.txt"
    return
        tc:is-endpoint-http200($url)
};

declare function tt:txt() {
    let $url := $tc:server || "textapi/ahiqar/syriac/sample_teixml.txt"
    let $req := tc:make-request($url)
    return http:send-request($req)[2] => util:base64-decode()
};


declare
    %test:assertXPath("$result/string() = '1234 5678'")
function tt:remove-whitespaces() as document-node() {
    let $doc := doc("/db/test-records/white-spaces.xml")
    return
        tapi:remove-whitespaces($doc)
};

declare
    %test:assertTrue
function tt:is-collection-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/arabic-karshuni/collection.json"
    return
        tc:is-endpoint-http200($url)
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'title')")
    %test:assertXPath("map:contains($result, 'collector')")
    %test:assertXPath("map:contains($result, 'description')")
    %test:assertXPath("map:contains($result, 'sequence')")
function tt:endpoint-collection()
as item() {
    let $url := $tc:server || "/textapi/ahikar/arabic-karshuni/collection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};

declare
    %test:assertTrue
function tt:is-manifest-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/arabic-karshuni/sample_edition_arabic/manifest.json"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'textapi')")
    %test:assertXPath("map:contains($result, 'id')")
    %test:assertXPath("map:contains($result, 'label')")
    %test:assertXPath("map:contains($result, 'metadata')")
    %test:assertXPath("map:contains($result, 'license')")
    %test:assertXPath("map:contains($result, 'annotationCollection')")
    %test:assertXPath("map:contains($result, 'sequence')")
    %test:assertXPath("map:contains($result, 'support')")
function tt:endpoint-manifest()
as item() {
    let $url := $tc:server || "/textapi/ahikar/syriac/sample_edition/manifest.json"
    let $req := tc:make-request($url)
    return
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
};

declare
    %test:assertTrue
function tt:is-sample-collection-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/sample/collection.json"
    return
        tc:is-endpoint-http200($url)
};


declare
    %test:assertTrue
function tt:is-sample-manifest-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/sample/sample_edition_tbd/manifest.json"
    return
        tc:is-endpoint-http200($url)
};
