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

import module namespace at="http://ahikar.sub.uni-goettingen.de/ns/annotations/tests" at "../tests/annotation-tests.xqm";
import module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests" at "../tests/commons-tests.xqm";
import module namespace et="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial/tests" at "../tests/editorial-tests.xqm";
import module namespace mt="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs/tests" at "../tests/motifs-tests.xqm";
import module namespace tct="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests" at "../tests/tapi-collection-tests.xqm";
import module namespace thtmlt="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests" at "../tests/tapi-html-tests.xqm";
import module namespace timgt="http://ahikar.sub.uni-goettingen.de/ns/tapi/images/tests" at "../tests/tapi-img-tests.xqm";
import module namespace titemt="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests" at "../tests/tapi-item-tests.xqm";
import module namespace tmt="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests" at "../tests/tapi-manifest-tests.xqm";
import module namespace ttnt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization/tests" at "../tests/tapi-txt-normalization-tests.xqm";
import module namespace t2ht="http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests" at "../tests/tei2html-tests.xqm";
import module namespace met="http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion/tests" at "../tests/motifs-expansion-tests.xqm";
import module namespace t2jt="http://ahikar.sub.uni-goettingen.de/ns/tei2json/tests" at "../tests/tei2json-tests.xqm";
import module namespace t2htextt="http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests" at "../tests/tei2html-textprocessing-tests.xqm";
import module namespace tokt="http://ahikar.sub.uni-goettingen.de/ns/tokenize/tests" at "../tests/tokenize-tests.xqm";
import module namespace st="http://ahikar.sub.uni-goettingen.de/ns/search/tests" at "../tests/search-tests.xqm";



(: modules that need credentials for the tests to work :)
import module namespace titemtc="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests/credentials" at "../tests/tapi-item-tests-credentials-needed.xqm";
import module namespace ttc="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests/credentials" at "../tests/tapi-tests-credentials-needed.xqm";
import module namespace ctc="http://ahikar.sub.uni-goettingen.de/ns/commons-tests/credentials" at "../tests/commons-tests-credentials-needed.xqm";

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
  %rest:path("/trigger-unit-tests")
  %rest:query-param("token", "{$token}")
function testtrigger:trigger($token)
as item()? {
  if( $token ne environment-variable("APP_DEPLOY_TOKEN" ))
    then error(QName("error://1", "deploy"), "Deploy token incorrect.")
  else
    let $sysout := util:log-system-out("TextAPI and package installation done. running tests…")
    let $tests := testtrigger:execute-tests()
    
    let $fileSeparator := util:system-property("file.separator")
    let $system-path := system:get-exist-home() || $fileSeparator
    
    let $testWrap := <tests time="{current-dateTime()}">{ $tests }</tests>
    
    let $filename := $system-path || "ahikar-test-results.xml"
    let $file := file:serialize($testWrap, $filename, ())
    
    return
        util:log-system-out("Tests complete. See " || $filename)
};

declare function testtrigger:execute-tests()
as element()+ {
    let $test-results :=
    (
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/commons-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/annotations/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/images/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tokenize/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tei2json/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/search/tests")),

        (: tests with credentials needed :)
        if (environment-variable("TGLOGIN")) then
            (
                test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests/credentials")),
                test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests/credentials")),
                test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/commons-tests/credentials"))
            )
        else
            ()
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
        case "http://ahikar.sub.uni-goettingen.de/ns/commons-tests" return "Commons"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests" return "TextAPI Collections"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests" return "TextAPI Manifests"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests" return "TextAPI Items"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests" return "HTML creation"
        case "http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests" return "TEI2HTML transformation"
        case "http://ahikar.sub.uni-goettingen.de/ns/tei2json/tests" return "TEI2JSON transformation"
        case "http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests" return "TEI2HTML text processing"
        case "http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion/tests" return "Motifs expansion"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization/tests" return "TXT normalization"
        case "http://ahikar.sub.uni-goettingen.de/ns/annotations/tests" return "AnnotationAPI"
        case "http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs/tests" return "Annotations: Motifs"
        case "http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial/tests" return "Annotations: Editorial comments"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/images/tests" return "Image Sections"
        case "http://ahikar.sub.uni-goettingen.de/ns/tokenize/tests" return "Tokenize"
        case "http://ahikar.sub.uni-goettingen.de/ns/search/tests" return "Search"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests/credentials" return "TextAPI Items (credentials needed)"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/tests/credentials" return "TextAPI general (credentials needed)"
        case "http://ahikar.sub.uni-goettingen.de/ns/commons-tests/credentials" return "Commons (credentials needed)"
        default return ()
};
