xquery version "3.1";
(:~
 : Script providing access to the test functions (XQSuite) for local unit test
 : execution.
 :)

import module namespace tct="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests" at "tests/tapi-collection-tests.xqm";
import module namespace ttnt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization/tests" at "tests/tapi-txt-normalization-tests.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tests="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests" at "tests.xqm";
import module namespace coll-tests="http://ahikar.sub.uni-goettingen.de/ns/coll-tests" at "tests/collate-tests.xqm";
import module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests" at "tests/commons-tests.xqm";

(: test API endpoints :)
test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests")),
test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/coll-tests")),
test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/commons-tests")),
test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests")),
test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization/tests"))