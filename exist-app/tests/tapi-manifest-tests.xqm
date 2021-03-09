xquery version "3.1";

module namespace tmt="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
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
    %test:args("sample_main_edition", "sample_edition")
    %test:assertXPath("matches(map:get($result[1], 'id'), '/api/textapi/ahikar/sample_main_edition/sample_edition-82a/latest/item.json')")
function tmt:make-sequences($collection-uri as xs:string,
    $manifest-uri as xs:string) {
    tapi-mani:make-sequences($collection-uri, $manifest-uri, $tc:server)
};

declare
     %test:args("sample_edition") %test:assertXPath("count($result) = 5")
function tmt:get-valid-page-ids($manifest-uri as xs:string) {
    tapi-mani:get-valid-page-ids($manifest-uri)
};

declare
    %test:args("sample_main_edition", "sample_edition")
    %test:assertXPath("map:get($result, 'label') = 'Beispieldatei zum Testen'")
    %test:assertXPath("matches(map:get($result, 'id'), '/api/textapi/ahikar/sample_main_edition/sample_edition/manifest.json')")
    %test:assertXPath("matches(map:get($result, 'annotationCollection'), '/api/annotations/ahikar/sample_main_edition/sample_edition/annotationCollection.json') ")
function tmt:get-json($collection-uri as xs:string,
    $manifest-uri as xs:string) {
    tapi-mani:get-json($collection-uri, $manifest-uri, $tc:server)
};

declare
    %test:args("sample_edition") %test:assertEquals("Beispieldatei zum Testen")
function tmt:get-manifest-title($manifest-uri as xs:string) {
    tapi-mani:get-manifest-title($manifest-uri)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'Simon Birol, Aly Elrefaei'")
function tmt:make-editors-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-editors($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'none'")
function tmt:make-editors-not-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-editors($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = '18.10.1697'")
function tmt:make-creation-date-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-creation-date($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'unknown'")
function tmt:make-creation-date-not-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-creation-date($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'Alqosh, Iraq'")
function tmt:make-origin-1() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'unknown'")
function tmt:make-origin-2() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'Iraq'")
function tmt:make-origin-3() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest2")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'Alqosh'")
function tmt:make-origin-4() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest3")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'University of Cambridge - Cambridge University Library, Great Britain'")
function tmt:make-current-location-1() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-current-location($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'unknown'")
function tmt:make-current-location-2() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-current-location($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'University of Cambridge - Cambridge University Library'")
function tmt:make-current-location-3() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest2")
    return
        tapi-mani:make-current-location($tei-xml)
};

declare
    %test:assertXPath("map:get($result, 'value') = 'Great Britain'")
function tmt:make-current-location-4() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest3")
    return
        tapi-mani:make-current-location($tei-xml)
};


declare
    %test:assertXPath("array:get($result, 1) => map:get('id') = 'CC-BY-SA-4.0'")
function tmt:get-license-info-provided() {
    let $tei-xml := doc("/db/data/textgrid/data/sample_teixml.xml")
    return
        tapi-mani:get-license-info($tei-xml)
};

declare
    %test:assertXPath("array:get($result, 1) => map:get('id') = 'no license provided'")
function tmt:get-license-info-not-provided() {
    let $tei-xml := doc("/db/data/textgrid/data/sample_3_teixml.xml")
    return
        tapi-mani:get-license-info($tei-xml)
};

declare
    %test:assertXPath("array:get($result, 1) => map:get('type') = 'css' ")
    %test:assertXPath("array:get($result, 1) => map:get('url') = 'http://0.0.0.0:8080/exist/restxq/api/content/ahikar.css' ")
function tmt:make-support-object()
as item() {
    tapi-mani:make-support-object($tc:server)
};

declare
    %test:assertXPath("count($result) = 4")
    %test:assertXPath("contains(map:get($result[1], 'url'), '/api/content/SyrCOMJerusalem') ")
function tmt:make-fonts()
as item()+ {
    tapi-mani:make-fonts($tc:server)
};
