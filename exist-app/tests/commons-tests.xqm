xquery version "3.1";

module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $ct:restxq := "http://0.0.0.0:8080/exist/restxq/";

declare
    %test:assertTrue
function ct:succes() {
    true()
};