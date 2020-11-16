xquery version "3.1";

module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $ct:restxq := "http://0.0.0.0:8080/exist/restxq/";

declare
    %test:args("sample_edition") %test:assertEquals("sample_teixml")
function ct:get-xml-uri($manifest-uri as xs:string)
as xs:string {
    commons:get-xml-uri($manifest-uri)
};

declare
    %test:args("sample_edition") %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh'")
function ct:get-tei-xml-for-manifest($manifest-uri) {
    commons:get-tei-xml-for-manifest($manifest-uri)
};


declare
    %test:args("sample_teixml", "data") %test:assertXPath("$result/*[local-name(.) = 'TEI']")
    %test:args("sample_teixml", "meta") %test:assertXPath("$result//* = 'Beispieldatei zum Testen'")
    %test:args("sample_edition", "agg") %test:assertXPath("$result//@* = 'textgrid:sample_teixml'")
    %test:args("sample_teixml", "sata") %test:assertError("COMMONS001")
    %test:args("qwerty", "data") %test:assertError("COMMONS002")
function ct:get-document($uri as xs:string,
    $type as xs:string)
as document-node()? {
    commons:get-document($uri, $type)
};

declare
    %test:args("sample_edition") %test:assertEquals("sample_teixml")
    %test:args("qwerty") %test:assertError("COMMONS002")
function ct:get-available-aggregates($uri as xs:string)
as xs:string+ {
    commons:get-available-aggregates($uri)
};
