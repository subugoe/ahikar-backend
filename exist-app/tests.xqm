xquery version "3.1";

(:~
 : Test module for the RESTXQ endpoints of the Ahikar TextAPI.
 : 
 : @author Michelle Weidling
 : @version 0.1.0
 :)

module namespace tests="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "modules/annotations.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi" at "modules/tapi.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $tests:restxq := "http://0.0.0.0:8080/exist/restxq/";


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
    </teiHeader>),
    tapi:zip-text()
};

declare
    %test:tearDown
function tests:_test-teardown() as item() {
    xmldb:remove("/db/test-records")
};

declare
    (: check if requests work :)
    %test:assertXPath("map:get($result, 'request') => map:get('scheme') = 'http'")
    (: check if expathpkg works :)
    %test:assertXPath("map:get($result, 'package') => map:get('title') = 'TextAPI for Ahikar'")
    (: check if repo.xml works :)
    %test:assertXPath("map:get($result, 'meta') => map:get('target') = 'ahikar'")
function tests:api-info()  as item() {
    let $url := $tests:restxq || "info"
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
     : no further tests are needed since the content has been tested by testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'textapi')")
    %test:assertXPath("map:contains($result, 'id')")
    %test:assertXPath("map:contains($result, 'label')")
    %test:assertXPath("map:contains($result, 'x-editor')")
    %test:assertXPath("map:contains($result, 'x-date')")
    %test:assertXPath("map:contains($result, 'x-origin')")
    %test:assertXPath("map:contains($result, 'x-location')")
    %test:assertXPath("map:contains($result, 'license')")
    %test:assertXPath("map:contains($result, 'sequence')")
function tests:manifest-rest() as item() {
    let $url := $tests:restxq || "/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json"
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
    %test:args("ahiqar_collection", "ahiqar_agg", "82a", "http://localhost:8080/exist/restxq")
    (: checks if the correct file has been opened :)
    %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh' ")
    (: checks if language assembling works correctly :)
    %test:assertXPath("$result//*[local-name(.) = 'lang'] = 'syc' ")
    %test:assertXPath("$result//*[local-name(.) = 'langAlt'] = 'karshuni' ")
    %test:assertXPath("$result//*[local-name(.) = 'x-langString'][matches(., 'Classical Syriac')]")
    (: checks if underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'content'] = 'http://localhost:8080/exist/restxq/api/content/ahiqar_sample-82a.html' ")
    (: checks if images connected to underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'id'] = 'http://localhost:8080/exist/restxq/api/images/3r1nz' ")
function tests:item($collection as xs:string, $document as xs:string, $page as xs:string, $server as xs:string) 
as element(object){
    tapi:item($collection, $document, $page, $server)
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
    %test:assertEquals("test test3 Berlin")
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
    %test:assertXPath("$result[local-name(.) = 'x-editor' and name/text() = 'Aly Elrefaei']")
function tests:make-editors() as element()+ {
    let $documentNode := doc("/db/apps/sade/textgrid/data/ahiqar_sample.xml")
    return
        tapi:make-editors($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-editor' and name/text() = 'none']")
function tests:make-editors-fail-gracefully() as element()+ {
    let $documentNode := doc("/db/test-records/sample-tei.xml")
    return
        tapi:make-editors($documentNode)
};


declare
    %test:assertXPath("$result[local-name(.) = 'x-date'][text() = '18.10.1697']")
function tests:make-date() as element() {
    let $documentNode := doc("/db/apps/sade/textgrid/data/ahiqar_sample.xml")
    return
        tapi:make-date($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-date'][text() = 'unknown']")
function tests:make-date-none() as element() {
    let $documentNode := doc("/db/test-records/header-empty-history-msIdentifier.xml")
    return
        tapi:make-date($documentNode)
};


declare
    %test:assertXPath("$result[local-name(.) = 'x-origin'][text() = 'Alqosh, Iraq']")
function tests:make-origin() as element() {
    let $documentNode := doc("/db/apps/sade/textgrid/data/ahiqar_sample.xml")
    return
        tapi:make-origin($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-origin'][text() = 'Iraq']")
function tests:make-origin-country-only() as element() {
    let $documentNode := doc("/db/test-records/origin-country-only.xml")
    return
        tapi:make-origin($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-origin'][text() = 'Alqosh']")
function tests:make-origin-place-only() as element() {
    let $documentNode := doc("/db/test-records/origin-place-only.xml")
    return
        tapi:make-origin($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-origin'][text() = 'unknown']")
function tests:make-origin-none() as element() {
    let $documentNode := doc("/db/test-records/header-empty-history-msIdentifier.xml")
    return
        tapi:make-origin($documentNode)
};


declare
    %test:assertXPath("$result[local-name(.) = 'x-location'][text() = 'University of Cambridge - Cambridge University Library, Great Britain']")
function tests:make-location() as element() {
    let $documentNode := doc("/db/apps/sade/textgrid/data/ahiqar_sample.xml")
    return
        tapi:make-location($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-location'][text() = 'Great Britain']")
function tests:make-location-country-only() as element() {
    let $documentNode := doc("/db/test-records/location-country-only.xml")
    return
        tapi:make-location($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-location'][text() = 'University of Cambridge - Cambridge University Library']")
function tests:make-location-institution-only() as element() {
    let $documentNode := doc("/db/test-records/location-institution-only.xml")
    return
        tapi:make-location($documentNode)
};

declare
    %test:assertXPath("$result[local-name(.) = 'x-location'][text() = 'unknown']")
function tests:make-location-none() as element() {
    let $documentNode := doc("/db/test-records/header-empty-history-msIdentifier.xml")
    return
        tapi:make-location($documentNode)
};


declare
    %test:assertXPath("$result/string() = '1234 5678'")
function tests:remove-whitespaces() as document-node() {
    let $doc := doc("/db/test-records/white-spaces.xml")
    return
        tapi:remove-whitespaces($doc)
};


declare
    %test:assertXPath("not($result//@rdf:resource[. = 'textgrid:3vp38'])")
    %test:assertXPath("$result//@rdf:resource[. = 'textgrid:3rx14']")
function tests:exclude-aggregated-manifests() {
    let $collection-metadata :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:3r9ps.0">
                <ore:aggregates rdf:resource="textgrid:3rbm9"/>
                <ore:aggregates rdf:resource="textgrid:3rbmc"/>
                <ore:aggregates rdf:resource="textgrid:3rx14"/>
                <ore:aggregates rdf:resource="textgrid:3vp38"/>
            </rdf:Description>
        </rdf:RDF>
    return
        tapi:exclude-unwanted-manifests($collection-metadata)
};


(:  
 : *****************
 : * AnnotationAPI * 
 : *****************
 :)
(::)
(:declare:)
(:    %test:args("ahiqar_sample", "data"):)
(:    %test:assertXPath("$result//*[local-name(.) = 'TEI']"):)
(:function tests:anno-get-document($uri as xs:string, $type as xs:string) as document-node() {:)
(:    anno:get-document($uri, $type):)
(:};:)
(::)
(::)
(:(:declare:):)
(:(:    %test:args("3r679", "114r"):):)
(:(:    %test:assertEquals("0"):):)
(:(:function tests:anno-determine-start-index-for-page($uri as xs:string, $page as xs:string) {:):)
(:(:    anno:determine-start-index-for-page($uri, $page):):)
(:(:};:):)
(:(::):)
(:(::):)
(:(:declare:):)
(:(:    %test:args("3r131"):):)
(:(:    %test:assertEquals("16"):):)
(:(:function tests:anno-determine-start-index($uri as xs:string) {:):)
(:(:    anno:determine-start-index($uri):):)
(:(:};:):)
(:(::):)
(:(:declare:):)
(:(:    %test:args("3r131"):):)
(:(:    %test:assertEquals("3r679"):):)
(:(:function tests:anno-get-parent-aggregation($uri as xs:string) {:):)
(:(:    anno:get-parent-aggregation($uri):):)
(:(:};:):)
(:(::):)
(:(::):)
(:(:declare:):)
(:(:    %test:args("3r131"):):)
(:(:    %test:assertEquals("114r", "114v"):):)
(:(:function tests:anno-get-pages-in-TEI($uri as xs:string) {:):)
(:(:    anno:get-pages-in-TEI($uri):):)
(:(:};:):)
(:(::):)
(:(::):)
(:(:declare:):)
(:(:    %test:args("3r679"):):)
(:(:    %test:assertTrue:):)
(:(:function tests:anno-is-resource-edition($uri as xs:string) {:):)
(:(:    anno:is-resource-edition($uri):):)
(:(:};:):)
(:(::):)
(:(::):)
(:(:declare:):)
(:(:    %test:args("3r131"):):)
(:(:    %test:assertTrue:):)
(:(:function tests:anno-is-resource-xml($uri as xs:string) {:):)
(:(:    anno:is-resource-xml($uri):):)
(:(:};:):)
(::)
(::)
(:declare:)
(:    %test:assertEquals("A place's name."):)
(:function tests:anno-get-bodyValue() {:)
(:    let $annotation := doc("/db/test-records/sample-tei.xml")//tei:placeName:)
(:    return:)
(:        anno:get-bodyValue($annotation):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("asdf"):)
(:    %test:assertFalse:)
(:(:    %test:args("3r131"):):)
(:(:    %test:assertTrue:):)
(:function tests:anno-are-resources-available($resources as xs:string+) {:)
(:    anno:are-resources-available($resources):)
(:};:)


(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("Simon Birol, Aly Elrefaei"):)
(:function tests:anno-get-creator($uri as xs:string) {:)
(:    anno:get-creator($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r131"):)
(:    %test:assertEquals("Brit. Lib. Add. 7200"):)
(:function tests:anno-get-metadata-title($uri as xs:string) {:)
(:    anno:get-metadata-title($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertEquals("3r676", "3r672"):)
(:function tests:anno-get-prev-xml-uris($uri as xs:string) {:)
(:    anno:get-prev-xml-uris($uri):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r679"):)
(:    %test:assertEquals("3r676", "3r672"):)
(:function tests:anno-get-xmls-prev-in-collection($uri as xs:string) {:)
(:    anno:get-xmls-prev-in-collection($uri):)
(:};:)


(:declare:)
(:    %test:args("3r679", "114r", "next"):)
(:    %test:assertEquals("114v"):)
(:function tests:anno-get-prev-or-next-page($documentURI as xs:string,:)
(:$page as xs:string, $type as xs:string) {:)
(:    anno:get-prev-or-next-page($documentURI, $page, $type):)
(:};:)
(::)
(::)
(:declare:)
(:    %test:args("3r9ps"):)
(:    %test:assertEquals("3r177", "3r178", "3r7vw", "3r7p1", "3r7p9", "3r7sk", "3r7tp", "3r7vd", "3r179", "3r7n0", "3r9vn", "3r9wf", "3rb3z", "3rbm9", "3rbmc", "3rx14", "3vp38"):)
(:function tests:anno-get-uris($documentURI) {:)
(:    anno:get-uris($documentURI):)
(:};:)