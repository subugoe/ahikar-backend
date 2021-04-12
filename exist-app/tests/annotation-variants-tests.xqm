xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace vars="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants" at "../modules/AnnotationAPI/annotations-variants.xqm";


declare
    %test:args("sample_teixml", "82a") %test:assertXPath("count($result) = 349")
function t:get-token-ids-on-page($teixml-uri as xs:string,
    $page as xs:string)
as xs:string+ {
    vars:get-token-ids-on-page($teixml-uri, $page)
};


declare
    %test:args("sample_teixml") %test:assertEquals("Add_2020")
function t:get-ms-id-from-idno($teixml-uri as xs:string)
as xs:string {
    vars:get-ms-id-from-idno($teixml-uri)
};

declare 
    %test:args("Sachau_336") %test:assertXPath("count($result) = 5")
function t:get-relevant-files($ms-id as xs:string)
as item()+ {
    vars:get-relevant-files($ms-id)
};

declare
    %test:args("Ar_7/229") %test:assertEquals("4")
function t:determine-id-position($ms-id as xs:string)
as xs:integer {
    let $json := vars:get-relevant-files($ms-id)
    return
        vars:determine-id-position($ms-id, $json[1])
};

