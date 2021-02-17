xquery version "3.1";

(: 
 : This module contains the unit tests for tei2html.xqm. 
 :)

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tokenize/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tei2html="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "../modules/tokenize.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare
    %test:assertTrue
function t:test-sample-data() {
    true()
};
