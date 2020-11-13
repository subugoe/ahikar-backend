xquery version "3.1";

module namespace at="http://ahikar.sub.uni-goettingen.de/ns/annotations/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module neEsamespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "../modules/annotations.xqm";

declare
    %test:assertTrue
function at:fail() {
    false()
};