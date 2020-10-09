xquery version "3.1";
(:~
 : Script providing access to the test functions (XQSuite) for local unit test
 : execution.
 : Elevated rights (dba/admin) are required for some tests.
 :)

import module namespace ttt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests" at "tapi-txt-tests.xqm";
import module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests" at "commons-tests.xqm";
import module namespace tct="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests" at "tapi-collection-tests.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace thtmlt="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests" at "tapi-html-tests.xqm";
import module namespace titemt="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests" at "tapi-item-tests.xqm";
import module namespace tmt="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests" at "tapi-manifest-tests.xqm";
import module namespace tt="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests" at "tapi-tests.xqm";


let $test-results :=
    (
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/commons-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests"))
    )

for $result in $test-results return
    if ($result//@failures = 0
    and $result//@errors = 0) then
        "Everything okay: " || $result//@package
    else
        $result