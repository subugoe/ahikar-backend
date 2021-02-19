xquery version "3.1";

module namespace thtmlt="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "../modules/tapi-html.xqm";



declare
    %test:args("sample_teixml", "82a") %test:assertXPath("$result//text()[matches(., 'حقًا')]")
    %test:args("sample_teixml", "82a")
    (: checks if there is text at all in the result :)
    %test:assertXPath("$result//text()[matches(., '[\w]')]")
    (: if a div[@class = 'tei_body'] is present, the transformation has been successfull :)
    %test:assertXPath("$result[@class = 'tei_body']")
    (: this is some text on 82a (and thus should be part of the result) :)
    %test:assertXPath("$result//* = 'ܟܒܪ'") 
    (: this is some text on 83a which shouldn't be part of the result :)
    %test:assertXPath("not($result//* = 'ܐܠܐܨܢܐܡ' )")
function thtmlt:get-html($tei-xml-uri as xs:string,
    $page as xs:string)
as element(div) {
    tapi-html:get-html($tei-xml-uri, $page)
};
