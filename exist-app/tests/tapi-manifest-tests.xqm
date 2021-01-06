xquery version "3.1";

module namespace tmt="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-mani="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest" at "../modules/tapi-manifest.xqm";

declare variable $tmt:manifest1 := "test-manifest1.xml";
declare variable $tmt:manifest2 := "test-manifest2.xml";
declare variable $tmt:manifest3 := "test-manifest3.xml";
declare variable $tmt:tei1-uri := "test-tei-1.xml";
declare variable $tmt:tei2-uri := "test-tei-2.xml";
declare variable $tmt:tei3-uri := "test-tei-3.xml";



declare
    %test:setUp
function tmt:_test-setup(){
    let $manifest1 :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description rdf:about="test-aggregation-1">
                <ore:aggregates rdf:resource="textgrid:test-tei-1"/>
            </rdf:Description>
        </rdf:RDF>
    let $manifest2 :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description rdf:about="test-aggregation-1">
                <ore:aggregates rdf:resource="textgrid:test-tei-2"/>
            </rdf:Description>
        </rdf:RDF>
    let $manifest3 :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description rdf:about="test-aggregation-1">
                <ore:aggregates rdf:resource="textgrid:test-tei-3"/>
            </rdf:Description>
        </rdf:RDF>
        
        
    let $tei1 :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title type="main">A Minimal Dummy TEI</title>
                    </titleStmt>
                </fileDesc>
            </teiHeader>
        </TEI>
        
        let $tei2 :=
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <teiHeader>
                    <fileDesc>
                        <titleStmt>
                            <title type="main">A Minimal Dummy TEI2</title>
                        </titleStmt>
                        <sourceDesc>
                            <msDesc>
                                <msIdentifier>
                                    <institution>University of Cambridge - Cambridge University Library</institution>
                                </msIdentifier>
                                <history>
                                    <origin>
                                        <country>Iraq</country>
                                    </origin>
                                </history>
                            </msDesc>
                        </sourceDesc>
                    </fileDesc>
                </teiHeader>
            </TEI>
        
        let $tei3 :=
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <teiHeader>
                    <fileDesc>
                        <titleStmt>
                            <title type="main">A Minimal Dummy TEI3</title>
                        </titleStmt>
                        <sourceDesc>
                            <msDesc>
                                <msIdentifier>
                                    <settlement>
                                        <country>Great Britain</country>
                                    </settlement>
                                </msIdentifier>
                                <history>
                                    <origin>
                                        <placeName>Alqosh</placeName>
                                    </origin>
                                </history>
                            </msDesc>
                        </sourceDesc>
                    </fileDesc>
                </teiHeader>
            </TEI>
        
        
    return
        (
            xmldb:store($commons:agg, $tmt:manifest1, $manifest1),
            xmldb:store($commons:agg, $tmt:manifest2, $manifest2),
            xmldb:store($commons:agg, $tmt:manifest3, $manifest3),
            xmldb:store($commons:data, $tmt:tei1-uri, $tei1),
            xmldb:store($commons:data, $tmt:tei2-uri, $tei2),
            xmldb:store($commons:data, $tmt:tei3-uri, $tei3)

        )
};

declare
    %test:tearDown
function tmt:_test-teardown() {
    xmldb:remove($commons:agg, $tmt:manifest1),
    xmldb:remove($commons:agg, $tmt:manifest2),
    xmldb:remove($commons:agg, $tmt:manifest3),
    xmldb:remove($commons:data, $tmt:tei1-uri),
    xmldb:remove($commons:data, $tmt:tei2-uri),
    xmldb:remove($commons:data, $tmt:tei3-uri)
};

declare
    %test:args("ahiqar_collection", "ahiqar_agg") %test:assertXPath("$result//id[matches(., '/api/textapi/ahikar/ahiqar_collection/ahiqar_agg-82a/latest/item.json')]")
function tmt:make-sequences($collection-uri as xs:string,
    $manifest-uri as xs:string) {
    tapi-mani:make-sequences($collection-uri, $manifest-uri, $tc:server)
};

declare
     %test:args("ahiqar_agg") %test:assertXPath("count($result) = 4")
function tmt:get-valid-page-ids($manifest-uri as xs:string) {
    tapi-mani:get-valid-page-ids($manifest-uri)
};

declare
    %test:args("ahiqar_collection", "ahiqar_agg")
    %test:assertXPath("$result//label = 'Beispieldatei zum Testen'")
    %test:assertXPath("$result//id[matches(., '/api/textapi/ahikar/ahiqar_collection/ahiqar_agg/manifest.json')]")
    %test:assertXPath("$result//annotationCollection[matches(., '/api/annotations/ahikar/ahiqar_collection/ahiqar_agg-82a/annotationCollection.json')] ")
function tmt:get-json($collection-uri as xs:string,
    $manifest-uri as xs:string) {
    tapi-mani:get-json($collection-uri, $manifest-uri, $tc:server)
};

declare
    %test:args("ahiqar_agg") %test:assertEquals("Beispieldatei zum Testen")
function tmt:get-manifest-title($manifest-uri as xs:string) {
    tapi-mani:get-manifest-title($manifest-uri)
};

declare
    %test:args("ahiqar_agg") %test:assertXPath("count($result) = 2")
    %test:args("ahiqar_agg") %test:assertXPath("$result//name = 'Simon Birol'")
    %test:args("test-manifest1") %test:assertXPath("count($result) = 1")
    %test:args("test-manifest1") %test:assertXPath("$result//name = 'none'")
function tmt:make-editors($manifest-uri as xs:string) {
    tapi-mani:make-editors($manifest-uri)
};

declare
    %test:args("ahiqar_agg") %test:assertXPath("$result/string() = '18.10.1697'")
    %test:args("test-manifest1") %test:assertXPath("$result/string() = 'unknown'")
function tmt:make-creation-date($manifest-uri as xs:string) {
    tapi-mani:make-creation-date($manifest-uri)
};

declare
    %test:args("ahiqar_agg") %test:assertXPath("$result/string() = 'Alqosh, Iraq'")
    %test:args("test-manifest1") %test:assertXPath("$result/string() = 'unknown'")
    %test:args("test-manifest2") %test:assertXPath("$result/string() = 'Iraq'")
    %test:args("test-manifest3") %test:assertXPath("$result/string() = 'Alqosh'")
function tmt:make-origin($manifest-uri as xs:string) {
    tapi-mani:make-origin($manifest-uri)
};

declare
    %test:args("ahiqar_agg") %test:assertXPath("$result/string() = 'University of Cambridge - Cambridge University Library, Great Britain'")
    %test:args("test-manifest1") %test:assertXPath("$result/string() = 'unknown'")
    %test:args("test-manifest2") %test:assertXPath("$result/string() = 'University of Cambridge - Cambridge University Library'")
    %test:args("test-manifest3") %test:assertXPath("$result/string() = 'Great Britain'")
function tmt:make-current-location($manifest-uri as xs:string) {
    tapi-mani:make-current-location($manifest-uri)
};

declare
     %test:args("ahiqar_collection", "ahiqar_agg") %test:assertExists
function tmt:get-json($collection-uri as xs:string,
    $manifest-uri as xs:string) {
    tapi-mani:get-json($collection-uri, $manifest-uri, $tc:server)
};
