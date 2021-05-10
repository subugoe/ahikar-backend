xquery version "3.1";
(:~
 : Script providing access to the test functions (XQSuite) for local unit test
 : execution.
 : Elevated rights (dba/admin) are required for some tests.
 :)

import module namespace apitests="http://ahikar.sub.uni-goettingen.de/ns/apitests" at "/db/apps/ahikar/modules/apitesttrigger.xqm";
import module namespace testtrigger="http://ahikar.sub.uni-goettingen.de/ns/testtrigger" at "../modules/testtrigger.xqm";

apitests:execute-tests(),
testtrigger:execute-tests()
