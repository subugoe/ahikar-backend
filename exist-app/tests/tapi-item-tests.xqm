xquery version "3.1";

module namespace titemt="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-item="http://ahikar.sub.uni-goettingen.de/ns/tapi/item" at "../modules/tapi-item.xqm";


declare
    %test:setUp
function titemt:_test-setup() {
    titemt:create-and-store-test-data()
};


declare
    %test:tearDown
function titemt:_test-teardown() {
    titemt:remove-test-data()
};


declare
    %test:args("sample_edition") %test:assertEquals("Arabic, Classical Syriac, Eastern Syriac, Karshuni, Western Syriac")
function titemt:get-language-string($manifest-uri as xs:string)
as xs:string {
    tapi-item:get-language-string($manifest-uri)
};


declare
    %test:args("sample_edition") 
    %test:assertXPath("array:get($result, 1) => map:get('title') = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh, king of Assyria and Nineveh'")
function titemt:make-title-object($manifest-uri as xs:string)
as item() {
    tapi-item:make-title-object($manifest-uri)
};

declare
    %test:args("sample_edition") %test:assertXPath("array:size($result) = 2")
    %test:args("sample_edition") %test:assertExists
function titemt:make-language-array($manifest-uri as xs:string)
as item() {
    tapi-item:make-language-array($manifest-uri)
};

declare
    %test:args("sample_edition") %test:assertXPath("array:size($result) = 3")
    %test:args("sample_edition") %test:assertExists
function titemt:make-langAlt-array($manifest-uri as xs:string)
as item() {
    tapi-item:make-langAlt-array($manifest-uri)
};


declare function titemt:create-and-store-test-data()
as xs:string+ {
    let $agg-wo-tile :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:sample_edition.0">
                <ore:aggregates rdf:resource="textgrid:ahiqar_sample_2"/>
            </rdf:Description>
        </rdf:RDF>
    let $agg-wo-tile-meta := commons:get-metadata-file("sample_edition")
        
    let $sample-xml-2 := commons:open-tei-xml("sample_teixml")
    let $sample-xml-2-meta := commons:get-metadata-file("sample_teixml")
        
    return
        (
            xmldb:store("/db/data/textgrid/agg", "ahiqar_agg_wo_tile.xml", $agg-wo-tile),
            xmldb:store("/db/data/textgrid/meta", "ahiqar_agg_wo_tile.xml", $agg-wo-tile-meta),

            xmldb:store("/db/data/textgrid/data", "ahiqar_sample_2.xml", $sample-xml-2),
            xmldb:store("/db/data/textgrid/meta", "ahiqar_sample_2.xml", $sample-xml-2-meta)
        )
};


declare function titemt:remove-test-data() {
    xmldb:remove("/db/data/textgrid/agg", "ahiqar_agg_wo_tile.xml"),
    xmldb:remove("/db/data/textgrid/data", "ahiqar_sample_2.xml"),
    xmldb:remove("/db/data/textgrid/meta", "ahiqar_sample_2.xml"),
    xmldb:remove("/db/data/textgrid/meta", "ahiqar_agg_wo_tile.xml")
};
