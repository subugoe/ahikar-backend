xquery version "3.1";
(:~
 : Script providing access to the test functions (XQSuite) for local unit test
 : execution.
 :)

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tests="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests" at "tests.xqm";


(: test API endpoints :)
test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests"))