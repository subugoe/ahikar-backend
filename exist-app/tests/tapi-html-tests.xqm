xquery version "3.1";

module namespace thtmlt="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "../modules/tapi-html.xqm";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "/db/apps/ahikar/tests/test-commons.xqm";


declare
    %test:args("sample_teixml", "82a", "transcription") %test:assertXPath("$result//text()[matches(., 'حقًا')]")
    %test:args("sample_teixml", "82a", "transliteration") %test:assertXPath("$result//text()[matches(., 'الحاسوب')]")
    %test:args("sample_teixml", "82a", "transcription")
    (: checks if there is text at all in the result :)
    %test:assertXPath("$result//text()[matches(., '[\w]')]")
    (: if a div[@class = 'tei_body'] is present, the transformation has been successfull :)
    %test:assertXPath("$result[@class = 'tei_body']")
    (: this is some text on 82a (and thus should be part of the result) :)
    %test:assertXPath("$result//* = 'ܟܒܪ'") 
    (: this is some text on 83a which shouldn't be part of the result :)
    %test:assertXPath("not($result//* = 'ܐܠܐܨܢܐܡ' )")
function thtmlt:get-html($tei-xml-uri as xs:string,
    $page as xs:string,
    $text-type as xs:string)
as element(div) {
    let $fragments :=
        map:get(tc:get-fragments(), $text-type)
        => map:get($page)
    return
        tapi-html:get-html($tei-xml-uri, $page, $fragments)
};
