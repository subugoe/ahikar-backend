xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-coll="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection" at "../modules/tapi-collection.xqm";

declare
    %test:args("syriac") %test:assertEquals("sample_lang_aggregation_syriac")
    %test:args("arabic-karshuni") %test:assertXPath("count($result) = 2 and $result = 'sample_lang_aggregation_arabic' and $result = 'sample_lang_aggregation_karshuni'")
function t:get-uris($collection-type as xs:string)
as xs:string+ {
    tapi-coll:get-uris($collection-type)
};

declare
    %test:args("syriac") %test:assertEquals("Syriac")
    %test:args("arabic-karshuni") %test:assertEquals("Arabic/Karshuni")
    %test:args("misc") %test:assertError("D001")
function t:get-collection-string($collection-type as xs:string)
as xs:string {
    tapi-coll:get-collection-string($collection-type)
};

declare
    %test:args("syriac") 
    %test:assertXPath("$result//description = 'Syriac collection for the Ahiqar project. Funded by DFG, 2019–2020. University of Göttingen'")
    %test:assertXPath("$result//title = 'The Story and Proverbs of Ahikar the Wise (Syriac Manuscripts)'")
    
    %test:args("arabic-karshuni") 
    %test:assertXPath("$result//description = 'Arabic/Karshuni collection for the Ahiqar project. Funded by DFG, 2019–2020. University of Göttingen'")
    %test:assertXPath("$result//title = 'The Story and Proverbs of Ahikar the Wise (Arabic and Karshuni Manuscripts)'")
function t:get-json($collection-type as xs:string) {
    tapi-coll:get-json($collection-type, $tc:server)
};


declare
    %test:args("syriac") %test:assertXPath("$result//type[. = 'manifest']")
    %test:args("syriac") %test:assertXPath("$result//id[contains(., 'textapi/ahikar/syriac/sample_edition/manifest.json')]")
    %test:args("arabic-karshuni") %test:assertXPath("$result//type[. = 'manifest']")
    %test:args("arabic-karshuni") %test:assertXPath("$result//id[contains(., 'textapi/ahikar/arabic-karshuni/sample_edition_arabic/manifest.json')]")
    %test:args("arabic-karshuni") %test:assertXPath("$result//id[contains(., 'textapi/ahikar/arabic-karshuni/sample_edition_karshuni/manifest.json')]")
function t:make-sequence($collection-type as xs:string) {
    tapi-coll:make-sequence($collection-type, $tc:server)
};

declare
    %test:args("sample_lang_aggregation_syriac") %test:assertExists
function t:get-aggregations_syriac($uris as xs:string+)
as document-node()+ {
    tapi-coll:get-aggregations($uris)
};

declare
    %test:assertExists
function t:get-aggregations_arabic_karshuni()
as document-node()+ {
    let $uris :=
        (
           "sample_lang_aggregation_arabic",
           "sample_lang_aggregation_karshuni"
        )
    return
        tapi-coll:get-aggregations($uris)
};

declare
    %test:args("textgrid:1234") %test:assertEquals("1234")
    %test:args("1234") %test:assertEquals("1234")
function t:remove-textgrid-prefix($uri as xs:string) {
    tapi-coll:remove-textgrid-prefix($uri)
};

declare
    %test:assertTrue
function t:get-allowed-manifest-uris-mock-up-input-included() {
    let $collection-metadata :=
    (
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:sample_lang_aggregation_arabic.0">
                <ore:aggregates rdf:resource="textgrid:3rbm9"/>
                <ore:aggregates rdf:resource="textgrid:3rbmc"/>
                <ore:aggregates rdf:resource="textgrid:3rx14"/>
                <ore:aggregates rdf:resource="textgrid:3vp38"/>
            </rdf:Description>
        </rdf:RDF>,
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:sample_lang_aggregation_karshuni.0">
                <ore:aggregates rdf:resource="textgrid:3rbm9"/>
                <ore:aggregates rdf:resource="textgrid:3rbmc"/>
                <ore:aggregates rdf:resource="textgrid:3rx14"/>
                <ore:aggregates rdf:resource="textgrid:3vp38"/>
            </rdf:Description>
        </rdf:RDF>
    )
    return
        tapi-coll:get-allowed-manifest-uris($collection-metadata) = "3rx14"
};

declare
    %test:assertFalse
function t:get-allowed-manifest-uris-mock-up-input-excluded() {
    let $collection-metadata :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:sample_lang_aggregation_syriac.0">
                <ore:aggregates rdf:resource="textgrid:3rbm9"/>
                <ore:aggregates rdf:resource="textgrid:3rbmc"/>
                <ore:aggregates rdf:resource="textgrid:3rx14"/>
                <ore:aggregates rdf:resource="textgrid:3vp38"/>
            </rdf:Description>
        </rdf:RDF>
    return
        tapi-coll:get-allowed-manifest-uris($collection-metadata) = "3vp38"
};

declare
    %test:args("syriac", "sample_edition") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/textapi/ahikar/syriac/sample_edition/manifest.json")
function t:make-id($colletion-type as xs:string, $manifest-uri as xs:string)
as xs:string {
    tapi-coll:make-id($tc:server, $colletion-type, $manifest-uri)
};

declare
    %test:args("text/tg.aggregation+xml") %test:assertEquals("collection")
    %test:args("text/tg.edition+tg.aggregation+xml") %test:assertEquals("manifest")
    %test:args("test") %test:assertEquals("manifest")
function t:make-format-type($tgmd-format as xs:string) {
    tapi-coll:make-format-type($tgmd-format)
};

declare
    %test:assertEquals("manifest")
function t:get-format-type() {
    let $metadata := commons:get-metadata-file("sample_edition")
    return
        tapi-coll:get-format-type($metadata)
};

declare
    %test:args("arabic-karshuni") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/annotations/ahikar/arabic-karshuni/annotationCollection.json")
function t:make-annotationCollection-uri($collection-uri as xs:string)
as xs:string {
    tapi-coll:make-annotationCollection-uri($tc:server, $collection-uri)
};
