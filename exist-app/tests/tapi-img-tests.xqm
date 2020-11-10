xquery version "3.1";

module namespace timgt="http://ahikar.sub.uni-goettingen.de/ns/tapi/images/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-img="http://ahikar.sub.uni-goettingen.de/ns/tapi/images" at "../modules/tapi-img.xqm";

declare
    %test:args("ahiqar_agg")
    %test:assertTrue
function timgt:has-manifest-tile($manifest-uri) as xs:boolean {
    tapi-img:has-manifest-tile($manifest-uri)
};

declare
    %test:args("ahiqar_sample") %test:assertFalse
    %test:args("ahiqar_tile") %test:assertTrue
function timgt:is-resource-tile($uri) as xs:boolean {
    tapi-img:is-resource-tile($uri)
};