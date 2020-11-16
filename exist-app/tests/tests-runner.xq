xquery version "3.1";
(:~
 : Script providing access to the test functions (XQSuite) for local unit test
 : execution.
 : Elevated rights (dba/admin) are required for some tests.
 :)

import module namespace testtrigger="http://ahikar.sub.uni-goettingen.de/ns/testtrigger" at "../modules/testtrigger.xqm";

testtrigger:execute-tests()