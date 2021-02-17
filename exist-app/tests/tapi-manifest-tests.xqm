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
    %test:args("sample_main_edition", "sample_edition") %test:assertXPath("$result//id[matches(., '/api/textapi/ahikar/sample_main_edition/sample_edition-82a/latest/item.json')]")
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
    %test:assertXPath("$result//label = 'Beispieldatei zum Testen'")
    %test:assertXPath("$result//id[matches(., '/api/textapi/ahikar/sample_main_edition/sample_edition/manifest.json')]")
    %test:assertXPath("$result//annotationCollection[matches(., '/api/annotations/ahikar/sample_main_edition/sample_edition/annotationCollection.json')] ")
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
    %test:assertXPath("count($result) = 2")
    %test:assertXPath("$result[self::value]/string() = 'Simon Birol, Aly Elrefaei'")
function tmt:make-editors-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-editors($tei-xml)
};

declare
    %test:assertXPath("count($result) = 2")
    %test:assertXPath("$result[self::value]/string() = 'none'")
function tmt:make-editors-not-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-editors($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = '18.10.1697'")
function tmt:make-creation-date-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-creation-date($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'unknown'")
function tmt:make-creation-date-not-present() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-creation-date($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'Alqosh, Iraq'")
function tmt:make-origin-1() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'unknown'")
function tmt:make-origin-2() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'Iraq'")
function tmt:make-origin-3() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest2")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'Alqosh'")
function tmt:make-origin-4() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest3")
    return
        tapi-mani:make-origin($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'University of Cambridge - Cambridge University Library, Great Britain'")
function tmt:make-current-location-1() {
    let $tei-xml := commons:get-tei-xml-for-manifest("sample_edition")
    return
        tapi-mani:make-current-location($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'unknown'")
function tmt:make-current-location-2() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest1")
    return
        tapi-mani:make-current-location($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'University of Cambridge - Cambridge University Library'")
function tmt:make-current-location-3() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest2")
    return
        tapi-mani:make-current-location($tei-xml)
};

declare
    %test:assertXPath("$result[self::value]/string() = 'Great Britain'")
function tmt:make-current-location-4() {
    let $tei-xml := commons:get-tei-xml-for-manifest("test-manifest3")
    return
        tapi-mani:make-current-location($tei-xml)
};


declare
    %test:args("https://creativecommons.org/licenses/by-sa/4.0/")
    %test:assertEquals("CC-BY-SA-4.0")
    %test:args("https://creativecommons.org/licenses/by-nc-sa/4.0/")
    %test:assertEquals("no license provided")
function tmt:get-spdx-for-license($target as xs:string)
as xs:string {
    tapi-mani:get-spdx-for-license($target)
};

declare
    %test:assertXPath("$result/type = 'css' ")
    %test:assertXPath("$result/url = 'https://gitlab.gwdg.de/subugoe/ahiqar/ahiqar-tido/-/blob/develop/ahikar.css' ")
function tmt:make-support-object()
as element() {
    tapi-mani:make-support-object()
};
