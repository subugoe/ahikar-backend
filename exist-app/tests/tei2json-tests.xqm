xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tei2json/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json" at "../modules/tei2json.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:assertEquals("works")
function t:main() {
    tei2json:main()
};