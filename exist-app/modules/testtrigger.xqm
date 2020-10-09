xquery version "3.1";

(:~
 : Providing an API endpoint for triggering test execution.
 : This endpoint has been established instead of the text execution in post-install.xq
 : since at this point the RESTXQ API isn't fired up yet which causes the tests to throw errors.
 : 
 : @author Michelle Weidling
 : @since 0.4.0
 :)

module namespace testtrigger="http://ahikar.sub.uni-goettingen.de/ns/testtrigger";

import module namespace rest="http://exquery.org/ns/restxq";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace ttt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests" at "../tests/tapi-txt-tests.xqm";
import module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests" at "../tests/commons-tests.xqm";
import module namespace tct="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests" at "../tests/tapi-collection-tests.xqm";
import module namespace thtmlt="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests" at "../tests/tapi-html-tests.xqm";
import module namespace titemt="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests" at "../tests/tapi-item-tests.xqm";
import module namespace tmt="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests" at "../tests/tapi-manifest-tests.xqm";
import module namespace tt="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests" at "../tests/tapi-tests.xqm";

(:~
 : Triggers the tests for the Ahikar backend. Called by the CI.
 : 
 : @param $token A CI token
 : @return item() A log message to std out. In the Docker environment, this goes to exist.log.
 : @error The deploy token provided is incorrect
 :)
declare
  %rest:GET
  %rest:path("/trigger-tests")
  %rest:query-param("token", "{$token}")
function testtrigger:trigger($token)
as item()? {
  if( $token ne environment-variable("APP_DEPLOY_TOKEN" ))
    then error(QName("error://1", "deploy"), "Deploy token incorrect.")
  else
    let $sysout := util:log-system-out("TextAPI and package installation done. running tests…")
    let $tests :=
        (
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests")),
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests")),
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/commons-tests")),
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests")),
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests")),
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests")),
            test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests"))
        )
    
    let $fileSeparator := util:system-property("file.separator")
    let $system-path := system:get-exist-home() || $fileSeparator
    
    let $testWrap := <tests time="{current-dateTime()}">{ $tests }</tests>
    
    let $filename := $system-path || "test-results.xml"
    let $file := file:serialize($testWrap, $filename, ())
    
    return
        util:log-system-out("Tests complete. See " || $filename)
};