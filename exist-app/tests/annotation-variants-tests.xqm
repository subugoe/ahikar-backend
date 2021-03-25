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