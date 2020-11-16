xquery version "3.1";

module namespace art="http://ahikar.sub.uni-goettingen.de/ns/annotations/rest/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace anno-rest="http://ahikar.sub.uni-goettingen.de/ns/annotations/rest" at "../modules/AnnotationAPI/annotations-rest.xqm";

declare
    %test:assertXPath("$result//@status = '404'")
    %test:assertXPath("$result//@message = 'One of the following requested resources couldn''t be found: qwerty, sample_teixml'")
function art:get-404-header()
as element() {
    let $resources := ("qwerty", "sample_teixml")
    return
       anno-rest:get-404-header($resources)
};