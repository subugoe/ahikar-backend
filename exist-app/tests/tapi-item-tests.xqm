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
    local:create-and-store-test-data()
};

declare
    %test:args("sample_edition", "82a") %test:assertEquals("3r1nz")
function titemt:get-facsimile-uri-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:get-facsimile-uri-for-page($manifest-uri, $page)
};

declare
    %test:args("sample_edition") %test:assertEquals("Arabic, Classical Syriac, Eastern Syriac, Karshuni, Western Syriac")
function titemt:get-language-string($manifest-uri as xs:string)
as xs:string {
    tapi-item:get-language-string($manifest-uri)
};

declare
    %test:args("sample_edition", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/3r1nz/50.03,0.48,49.83,100.00")
(:  TODO: old name used here. dont know how to translate.
    %test:args("ahiqar_agg_wo_tile", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/3r1nz")
    %test:args("sample_edition", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/3r1nz")
:)
function titemt:make-facsimile-id($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:make-facsimile-id($manifest-uri, $page, $tc:server)
};

declare
    %test:args("sample_edition") %test:assertEquals("The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh")
function titemt:make-title($manifest-uri as xs:string)
as xs:string {
    tapi-item:make-title($manifest-uri)
};


declare
    %test:args("sample_main_edition", "sample_edition", "82a")
    (: checks if the correct file has been opened :)
    %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh' ")
    (: checks if language assembling works correctly :)
    %test:assertXPath("$result//*[local-name(.) = 'lang'] = 'syc' ")
    %test:assertXPath("$result//*[local-name(.) = 'langAlt'] = 'karshuni' ")
    %test:assertXPath("$result//*[local-name(.) = 'x-langString'][matches(., 'Classical Syriac')]")
    (: checks if underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'content'] = 'http://0.0.0.0:8080/exist/restxq/api/content/sample_teixml-82a.html' ")
    (: checks if images connected to underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'id'] = 'http://0.0.0.0:8080/exist/restxq/api/images/3r1nz' ")
    %test:assertXPath("$result//*[local-name(.) = 'annotationCollection'] = 'http://0.0.0.0:8080/exist/restxq/api/annotations/ahikar/sample_main_edition/sample_edition/82a/annotationCollection.json' ")
function titemt:get-json($collection as xs:string,
    $document as xs:string,
    $page as xs:string) 
as element(object){
    tapi-item:get-json($collection, $document, $page, $tc:server)
};


declare
    %test:args("sample_edition") %test:assertXPath("count($result) = 5")
    %test:args("sample_edition") %test:assertXPath("$result[local-name(.) = ('lang', 'langAlt')]")
    %test:args("sample_edition") %test:assertXPath("count($result[local-name(.) = 'lang']) = 2")
function titemt:make-language-elements($manifest-uri as xs:string)
as element()+ {
    tapi-item:make-language-elements($manifest-uri)
};


declare
    %test:args("3r1nz") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/3r1nz")
function titemt:make-url-for-single-page-image($facsimile-uri as xs:string)
as xs:string {
    tapi-item:make-url-for-single-page-image($facsimile-uri, $tc:server)
};

declare
    %test:args("3r1nz", "ahiqar_agg", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/3r1nz/50.03,0.48,49.83,100.00")
function titemt:make-url-for-double-page-image($facsimile-uri as xs:string,
    $manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:make-url-for-double-page-image($facsimile-uri, $manifest-uri, $page, $tc:server)
};


declare function local:create-and-store-test-data()
as xs:string+ {
    let $agg-wo-tile :=
        <rdf:RDF xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0" rdf:about="textgrid:ahiqar_agg.0">
                <ore:aggregates rdf:resource="textgrid:ahiqar_sample_2"/>
            </rdf:Description>
        </rdf:RDF>
    let $agg-wo-tile-meta := commons:get-metadata-file("ahiqar_agg")
        
    let $sample-xml-2 := commons:open-tei-xml("ahiqar_sample")
    let $sample-xml-2-meta := commons:get-metadata-file("ahiqar_sample")
        
    return
        (
            xmldb:store("/db/apps/sade/textgrid/agg", "ahiqar_agg_wo_tile.xml", $agg-wo-tile),
            xmldb:store("/db/apps/sade/textgrid/data", "ahiqar_sample_2.xml", $sample-xml-2),
            xmldb:store("/db/apps/sade/textgrid/meta", "ahiqar_sample_2.xml", $sample-xml-2-meta),
            xmldb:store("/db/apps/sade/textgrid/meta", "ahiqar_agg_wo_tile.xml", $agg-wo-tile-meta)
        )
};
