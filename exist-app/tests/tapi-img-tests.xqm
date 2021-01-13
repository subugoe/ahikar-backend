xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tapi/images/tests";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-img="http://ahikar.sub.uni-goettingen.de/ns/tapi/images" at "../modules/tapi-img.xqm";

declare
    %test:setUp
function t:_test-setup() {
    local:create-and-store-test-data()
};

declare
    %test:tearDown
function t:_test-teardown() {
    local:remove-test-data()
};

declare
    %test:args("sample_edition")
    %test:assertTrue
function t:has-manifest-tile($manifest-uri) as xs:boolean {
    tapi-img:has-manifest-tile($manifest-uri)
};

declare
    %test:args("sample_teixml") %test:assertFalse
    %test:args("ahiqar_tile") %test:assertTrue
function t:is-resource-tile($uri) as xs:boolean {
    tapi-img:is-resource-tile($uri)
};

declare
    %test:args("ahiqar_tile") %test:assertTrue
    (: the following is a sample for a resource that's not available in the db :)
    %test:args("ahiqar_tile-non-existent") %test:assertFalse
function t:is-tile-available($tile-uri as xs:string)
as xs:boolean {
    tapi-img:is-tile-available($tile-uri)
};

declare
    %test:args("sample_edition") %test:assertEquals("ahiqar_tile")
function t:get-tile-uri($manifest-uri as xs:string)
as xs:string {
    tapi-img:get-tile-uri($manifest-uri)
};


declare
    %test:args("sample_edition") %test:assertXPath("$result//*[local-name(.) = 'rect']")
function t:get-tile($manifest-uri as xs:string)
as document-node() {
    tapi-img:get-tile($manifest-uri)
};


declare
    %test:args("sample_edition", "82a") %test:assertEquals("3r1nz")
    %test:args("ahiqar_agg_wo_tile", "82b") %test:assertEquals("3r1p0")
function t:get-facsimile-uri-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-img:get-facsimile-uri-for-page($manifest-uri, $page)
};

declare
    %test:args("sample_edition", "82a") %test:assertEquals("a1")
function t:get-xml-id-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-img:get-xml-id-for-page($manifest-uri, $page)
};

declare
    %test:args("sample_edition", "a1") %test:assertEquals("shape-1")
function t:get-shape-id($manifest-uri as xs:string,
    $page-id as xs:string)
as xs:string {
    tapi-img:get-shape-id($manifest-uri, $page-id)
};

declare
    %test:args("shape-1") %test:assertXPath("$result[@id = 'shape-1']")
function t:get-svg-rect($shape-id as xs:string)
as element() {
    let $tile := tapi-img:get-tile("sample_edition")
    return
        tapi-img:get-svg-rect($tile, $shape-id)
};

declare
    %test:assertEquals("50.03,0.48,49.83,100.00")
function t:get-svg-section-dimensions-as-string()
as xs:string {
    let $manifest-uri := "sample_edition"
    let $shape-id := "shape-1"
    let $tile := tapi-img:get-tile($manifest-uri)
    let $svg := tapi-img:get-svg-rect($tile, $shape-id)
    return
        tapi-img:get-svg-section-dimensions-as-string($svg)
};

declare
    %test:args("sample_edition", "82a") %test:assertEquals("50.03,0.48,49.83,100.00")
function t:get-relevant-image-section($manifest-uri as xs:string,
    $page-uri as xs:string)
as xs:string {
    tapi-img:get-relevant-image-section($manifest-uri, $page-uri)
};

declare function local:create-and-store-test-data()
as xs:string+ {
    let $agg-wo-tile :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:ahiqar_agg.0">
                <ore:aggregates rdf:resource="textgrid:ahiqar_sample_2"/>
            </rdf:Description>
        </rdf:RDF>
    let $agg-wo-tile-meta := commons:get-metadata-file("sample_edition")
        
    let $sample-xml-2 := commons:open-tei-xml("sample_teixml")
    let $sample-xml-2-meta := commons:get-metadata-file("sample_teixml")
        
    return
        (
            xmldb:store("/db/apps/sade/textgrid/agg", "ahiqar_agg_wo_tile.xml", $agg-wo-tile),
            xmldb:store("/db/apps/sade/textgrid/data", "ahiqar_sample_2.xml", $sample-xml-2),
            xmldb:store("/db/apps/sade/textgrid/meta", "ahiqar_sample_2.xml", $sample-xml-2-meta),
            xmldb:store("/db/apps/sade/textgrid/meta", "ahiqar_agg_wo_tile.xml", $agg-wo-tile-meta)
        )
};

declare function local:remove-test-data() {
    xmldb:remove("/db/apps/sade/textgrid/agg", "ahiqar_agg_wo_tile.xml"),
    xmldb:remove("/db/apps/sade/textgrid/data", "ahiqar_sample_2.xml"),
    xmldb:remove("/db/apps/sade/textgrid/meta", "ahiqar_sample_2.xml"),
    xmldb:remove("/db/apps/sade/textgrid/meta", "ahiqar_agg_wo_tile.xml")
};
