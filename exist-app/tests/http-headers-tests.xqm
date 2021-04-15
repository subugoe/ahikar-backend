xquery version "3.1";

module namespace ht="http://ahikar.sub.uni-goettingen.de/ns/http-headers/tests";

import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:assertEquals("403")
function ht:http-403()
as xs:string {
    let $url := $tc:server || "/http-403"
    return
        tc:get-http-status($url)
};

declare
    %test:assertEquals("404")
function ht:http-404()
as xs:string {
    let $url := $tc:server || "/http-404"
    return
        tc:get-http-status($url)
};

declare
    %test:assertEquals("500")
function ht:http-500()
as xs:string {
    let $url := $tc:server || "/http-500"
    return
        tc:get-http-status($url)
};

declare
    %test:assertEquals("503")
function ht:http-503()
as xs:string {
    let $url := $tc:server || "/http-503"
    return
        tc:get-http-status($url)
};
