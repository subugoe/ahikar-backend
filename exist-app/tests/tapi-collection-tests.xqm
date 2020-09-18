xquery version "3.1";

module namespace tct="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace t-coll="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection" at "../modules/tapi-collection.xqm";

declare variable $tct:restxq := "http://0.0.0.0:8080/exist/restxq";
declare variable $tct:collection-uri := "test-collection.xml";
declare variable $tct:agg1-uri := "test-aggregation-1.xml";
declare variable $tct:agg2-uri := "test-aggregation-2.xml";

declare
    %test:setUp
function tct:_test-setup(){
    let $collection :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" 
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description rdf:about="textgrid:test-collection">
                <ore:aggregates rdf:resource="textgrid:test-aggregation-1"/>
                <ore:aggregates rdf:resource="textgrid:test-aggregation-2"/>
            </rdf:Description>
        </rdf:RDF>
    let $collection-meta :=
        <MetadataContainerType xmlns="http://textgrid.info/namespaces/metadata/core/2010"
            xmlns:ns2="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <object>
                <generic>
                    <provided>
                        <title>Beispieldatei zum Testen</title>
                        <format>text/tg.edition+tg.aggregation+xml</format>
                    </provided>
                </generic>
            </object>
        </MetadataContainerType>
        
    let $agg1 :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description rdf:about="test-aggregation-1">
                <ore:aggregates rdf:resource="textgrid:ahiqar_sample"/>
            </rdf:Description>
        </rdf:RDF>
    let $agg1-meta :=
        <MetadataContainerType xmlns="http://textgrid.info/namespaces/metadata/core/2010"
            xmlns:ns2="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <object>
                <generic>
                    <provided>
                        <title>Beispielagg1 zum Testen</title>
                        <format>text/tg.edition+tg.aggregation+xml</format>
                    </provided>
                </generic>
            </object>
        </MetadataContainerType>
        
    let $agg2 := 
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description rdf:about="test-aggregation-2">
                <ore:aggregates rdf:resource="textgrid:ahiqar_sample"/>
            </rdf:Description>
        </rdf:RDF>
    let $agg2-meta :=
        <MetadataContainerType xmlns="http://textgrid.info/namespaces/metadata/core/2010"
            xmlns:ns2="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <object>
                <generic>
                    <provided>
                        <title>Beispielagg2 zum Testen</title>
                        <format>text/tg.edition+tg.aggregation+xml</format>
                    </provided>
                </generic>
            </object>
        </MetadataContainerType>
        
        
    return
        (
            xmldb:store($commons:agg, $tct:collection-uri, $collection),
            xmldb:store($commons:agg, $tct:agg1-uri, $agg1),
            xmldb:store($commons:agg, $tct:agg2-uri, $agg2),
            xmldb:store($commons:meta, $tct:collection-uri, $collection-meta),
            xmldb:store($commons:meta, $tct:agg1-uri, $agg1-meta),
            xmldb:store($commons:meta, $tct:agg2-uri, $agg2-meta)
        )
};

declare
    %test:tearDown
function tct:_test-teardown() {
    xmldb:remove($commons:agg, $tct:collection-uri),
    xmldb:remove($commons:agg, $tct:agg1-uri),
    xmldb:remove($commons:agg, $tct:agg2-uri),
    xmldb:remove($commons:meta, $tct:collection-uri),
    xmldb:remove($commons:meta, $tct:agg1-uri),
    xmldb:remove($commons:meta, $tct:agg2-uri)
};

declare
    %test:assertTrue
function tct:is-endpoint-available() {
    let $url := $tct:restxq || "/textapi/ahikar/ahiqar_collection/collection.json"
    return
        local:is-endpoint-http200($url)
};

declare
    %test:args("ahiqar_collection") %test:assertXPath("$result//*[local-name(.) = 'aggregates']")
function tct:get-aggregation($uri as xs:string) {
    t-coll:get-aggregation($uri)
};

declare
    %test:assertTrue
function tct:get-allowed-manifest-uris-mock-up-input-included() {
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
        t-coll:get-allowed-manifest-uris($collection-metadata) = "3rx14"
};

declare
    %test:assertFalse
function tct:get-allowed-manifest-uris-mock-up-input-excluded() {
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
        t-coll:get-allowed-manifest-uris($collection-metadata) = "3vp38"
};


declare
    %test:args("ahiqar_collection", "ahiqar_agg") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json")
function tct:make-id($colletion-uri as xs:string, $manifest-uri as xs:string)
as xs:string {
    t-coll:make-id($tct:restxq, $colletion-uri, $manifest-uri)
};


declare
    %test:assertEquals("ahiqar_agg")
function tct:get-allowed-manifest-uris-sample-input() {
    let $collection-metadata := t-coll:get-aggregation("ahiqar_collection")
    return
        t-coll:get-allowed-manifest-uris($collection-metadata)
};

declare
    %test:args("ahiqar_collection") %test:assertXPath("$result[self::document-node()]")
function tct:get-metadata-file($uri as xs:string) {
    t-coll:get-metadata-file($uri)
};


declare
    %test:args("textgrid:1234") %test:assertEquals("1234")
    %test:args("1234") %test:assertEquals("1234")
function tct:remove-textgrid-prefix($uri as xs:string) {
    t-coll:remove-textgrid-prefix($uri)
};

declare
    %test:args("text/tg.aggregation+xml") %test:assertEquals("collection")
    %test:args("text/tg.edition+tg.aggregation+xml") %test:assertEquals("manifest")
    %test:args("test") %test:assertEquals("manifest")
function tct:make-format-type($tgmd-format as xs:string) {
    t-coll:make-format-type($tgmd-format)
};

declare
    %test:assertEquals("manifest")
function tct:get-format-type() {
    let $metadata := t-coll:get-metadata-file("ahiqar_agg")
    return
        t-coll:get-format-type($metadata)
};


declare
    %test:args("ahiqar_collection") %test:assertXPath("$result//type[. = 'manifest']")
    %test:args("ahiqar_collection") %test:assertXPath("$result//id[matches(., 'ahiqar_agg/manifest.json')]")
    %test:args("test-collection") %test:assertXPath("$result//id[matches(., 'test-aggregation-1/manifest.json')]")
    %test:args("test-collection") %test:assertXPath("$result//id[matches(., 'test-aggregation-2/manifest.json')]")
function tct:make-sequence($collection-uri as xs:string) {
    t-coll:make-sequence($collection-uri, $tct:restxq)
};

declare
    %test:args("ahiqar_collection") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/textapi/ahikar/ahiqar_collection/annotationCollection.json")
function tct:make-annotationCollection-uri($collection-uri as xs:string)
as xs:string {
    t-coll:make-annotationCollection-uri($tct:restxq, $collection-uri)
};


declare
    %test:args("ahiqar_collection") %test:assertXPath("$result//title = 'The Story and Proverbs of Ahikar the Wise'")
    %test:args("ahiqar_collection") %test:assertXPath("$result//*/string() = 'http://0.0.0.0:8080/exist/restxq/api/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json' ")
function tct:get-json($collection-uri as xs:string) {
    t-coll:get-json($collection-uri, $tct:restxq)
};


declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'title')")
    %test:assertXPath("map:contains($result, 'collector')")
    %test:assertXPath("map:contains($result, 'description')")
    %test:assertXPath("map:contains($result, 'sequence')")
function tct:endpoint()
as item() {
    let $url := $tct:restxq || "/textapi/ahikar/ahiqar_collection/collection.json"
    let $req := <http:request href="{$url}" method="get">
                        <http:header name="Connection" value="close"/>
                   </http:request>
    return http:send-request($req)[2] => util:base64-decode() => parse-json()
};




declare function local:is-endpoint-http200($url as xs:string) as xs:boolean {
    let $http-status := local:get-http-status($url)
    return
        $http-status = "200"
};

declare function local:get-http-status($url as xs:string) as xs:string {
    let $req := local:make-request($url)
    return
        http:send-request($req)[1]/@status
};

declare function local:make-request($url as xs:string) {
    <http:request href="{$url}" method="get">
        <http:header name="Connection" value="close"/>
   </http:request>
};