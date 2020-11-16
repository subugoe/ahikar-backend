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
import module namespace t2ht="http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests" at "tei2html-tests.xqm";
import module namespace t2htextt="http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests" at "tei2html-textprocessing-tests.xqm";
import module namespace at="http://ahikar.sub.uni-goettingen.de/ns/annotations/tests" at "../tests/annotation-tests.xqm";

declare function local:get-human-readable-pkg-name($package as xs:string)
as xs:string? {
    switch ($package)
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/tests" return "TextAPI general"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests" return "TXT creation"
        case "http://ahikar.sub.uni-goettingen.de/ns/commons-tests" return "Commons"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests" return "TextAPI Collections"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests" return "TextAPI Manifests"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests" return "TextAPI Items"
        case "http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests" return "HTML creation"
        case "http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests" return "TEI2HTML transformation"
        case "http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests" return "TEI2HTML text processing"
        case "http://ahikar.sub.uni-goettingen.de/ns/annotations/tests" return "AnnotationAPI"
        default return ()
};

let $test-results :=
    (
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/commons-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/collection/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests")),
        test:suite(util:list-functions("http://ahikar.sub.uni-goettingen.de/ns/annotations/tests"))
    )

for $result in $test-results
order by $result//@package return
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
        