xquery version "3.1";

(:~
 : Providing an API endpoint for triggering test execution.
 : This endpoint has been established instead of the text execution in post-install.xq
 : since at this point the RESTXQ API isn't fired up yet which causes the tests to throw errors.
 : 
 : @author Michelle Weidling
 : @since 0.4.0
 :)

module namespace apitests="http://ahikar.sub.uni-goettingen.de/ns/apitests";

import module namespace rest="http://exquery.org/ns/restxq";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace art="http://ahikar.sub.uni-goettingen.de/ns/annotations/rest/tests" at "../tests/annotation-rest-tests.xqm";
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
  %rest:HEAD
  %rest:path("/trigger-api-tests")
  %rest:query-param("token", "{$token}")
function apitests:trigger($token)
as item()? {
  if( $token ne environment-variable("APP_DEPLOY_TOKEN" ))
    then error(QName("error://1", "deploy"), "Deploy token incorrect.")
  else
    let $sysout := util:log-system-out("TextAPI and package installation done. running API tests…")
    let $tests := apitests:execute-tests()
    
    let $fileSeparator := util:system-property("file.separator")
    let $system-path := system:get-exist-home() || $fileSeparator
    
    let $testWrap := <tests time="{current-dateTime()}">{ $tests }</tests>
    
    let $filename := $system-path || "ahikar-test-results.xml"
    let $file := file:serialize($testWrap, $filename, ())
    
    return
        util:log-system-out("Tests complete. See " || $filename)
};

declare function apitests:execute-tests()
as element()+ {
    let $test-results :=
    (
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/annotations/rest/tests"))
    )

    let $results := for $result in $test-results return
        if ($result//@failures = 0
        and $result//@errors = 0) then
            <OK name="{local:get-human-readable-pkg-name($result//@package)}" package="{$result//@package}"/>
        else
            <PROBLEM name="{local:get-human-readable-pkg-name($result//@package)}"
                package="{$result//@package}"
                errors="{$result//@errors}"
                failures="{$result//@failures}">
                {$result//testcase[child::*[self::failure or self::error]]}
            </PROBLEM>
            
    for $result in $results
    order by $result/name() descending return
        $result
};

declare function local:get-human-readable-pkg-name($package as xs:string)
as xs:string? {
    switch ($package)
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/tests" return "TextAPI general"
        case "http://ahikar.sub.uni-goettingen.de/ns/annotations/rest/tests" return "AnnotationAPI REST"
        default return ()
};
