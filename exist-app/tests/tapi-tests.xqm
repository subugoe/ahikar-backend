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

import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "../modules/annotations.xqm";
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
    %test:assertXPath("map:get($result, 'package') => map:get('title') = 'TextAPI for Ahikar'")
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
    let $url := $tc:server || "/content/ahiqar_sample-82a.html"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if tei:div is present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("$result//*[@class = 'tei_body']")
function tt:content-rest() as document-node() {
    let $url := $tc:server || "/content/ahiqar_sample-82a.html"
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
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/ahiqar_sample.txt"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2]
};


declare
    %test:assertTrue
function tt:is-txt-api-available() {
    let $url := $tc:server || "/content/ahiqar_sample.txt"
    return
        tc:is-endpoint-http200($url)
};

declare function tt:txt() {
    let $url := $tc:server || "textapi/ahiqar/ahiqar_collection/ahiqar_sample.txt"
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
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/collection.json"
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
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/collection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};

declare
    %test:assertTrue
function tt:is-manifest-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json"
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
    %test:assertXPath("map:contains($result, 'x-editor')")
    %test:assertXPath("map:contains($result, 'x-date')")
    %test:assertXPath("map:contains($result, 'x-origin')")
    %test:assertXPath("map:contains($result, 'x-location')")
    %test:assertXPath("map:contains($result, 'license')")
    %test:assertXPath("map:contains($result, 'annotationCollection')")
    %test:assertXPath("map:contains($result, 'sequence')")
function tt:endpoint-manifest()
as item() {
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json"
    let $req := tc:make-request($url)
    return
        http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
};

declare
    %test:assertTrue
function tt:is-item-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/ahiqar_agg-82a/latest/item.json"
    return
        tc:is-endpoint-http200($url)
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
    %test:assertXPath("map:contains($result, 'langAlt')")
    %test:assertXPath("map:contains($result, 'image')")
function tt:endpoint-item() as item() {
    let $url := $tc:server || "/textapi/ahikar/ahiqar_collection/ahiqar_agg-82a/latest/item.json"
    let $req := tc:make-request($url)
    return http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
};


(:  
 : *****************
 : * AnnotationAPI * 
 : *****************
 :)

declare
    %test:args("ahiqar_sample", "data")
    %test:assertXPath("$result//*[local-name(.) = 'TEI']")
function tt:anno-get-document($uri as xs:string, $type as xs:string) as document-node() {
    anno:get-document($uri, $type)
};


(:declare:)
(:    %test:args("3r679", "114r"):)
(:    %test:assertEquals("0"):)
(:function tt:anno-determine-start-index-for-page($uri as xs:string, $page as xs:string) {:)
(:    anno:determine-start-index-for-page($uri, $page):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("16"):)
(:function tt:anno-determine-start-index($uri as xs:string) {:)
(:    anno:determine-start-index($uri):)
(:};:)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("3r679"):)
(:function tt:anno-get-parent-aggregation($uri as xs:string) {:)
(:    anno:get-parent-aggregation($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("114r", "114v"):)
(:function tt:anno-get-pages-in-TEI($uri as xs:string) {:)
(:    anno:get-pages-in-TEI($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertTrue:)
(:function tt:anno-is-resource-edition($uri as xs:string) {:)
(:    anno:is-resource-edition($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertTrue:)
(:function tt:anno-is-resource-xml($uri as xs:string) {:)
(:    anno:is-resource-xml($uri):)
(:};:)


declare
    %test:assertEquals("A place's name.")
function tt:anno-get-bodyValue() {
    let $annotation := doc("/db/test-records/sample-tei.xml")//tei:placeName
    return
        anno:get-bodyValue($annotation)
};


declare
    %test:args("asdf")
    %test:assertFalse
(:    %test:args("3r131"):)
(:    %test:assertTrue:)
function tt:anno-are-resources-available($resources as xs:string+) {
    anno:are-resources-available($resources)
};


(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("Simon Birol, Aly Elrefaei"):)
(:function tt:anno-get-creator($uri as xs:string) {:)
(:    anno:get-creator($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("Brit. Lib. Add. 7200"):)
(:function tt:anno-get-metadata-title($uri as xs:string) {:)
(:    anno:get-metadata-title($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertEquals("3r676", "3r672"):)
(:function tt:anno-get-prev-xml-uris($uri as xs:string) {:)
(:    anno:get-prev-xml-uris($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertEquals("3r676", "3r672"):)
(:function tt:anno-get-xmls-prev-in-collection($uri as xs:string) {:)
(:    anno:get-xmls-prev-in-collection($uri):)
(:};:)


(:declare:)
(:    %test:args("3r679", "114r", "next"):)
(:    %test:assertEquals("114v"):)
(:function tt:anno-get-prev-or-next-page($documentURI as xs:string,:)
(:$page as xs:string, $type as xs:string) {:)
(:    anno:get-prev-or-next-page($documentURI, $page, $type):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r9ps"):)
(:    %test:assertEquals("3r177", "3r178", "3r7vw", "3r7p1", "3r7p9", "3r7sk", "3r7tp", "3r7vd", "3r179", "3r7n0", "3r9vn", "3r9wf", "3rb3z", "3rbm9", "3rbmc", "3rx14", "3vp38"):)
(:function tt:anno-get-uris($documentURI) {:)
(:    anno:get-uris($documentURI):)
(:};:)
