xquery version "3.1";

module namespace titemt="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-item="http://ahikar.sub.uni-goettingen.de/ns/tapi/item" at "../modules/tapi-item.xqm";


declare
    %test:args("ahiqar_agg", "82a") %test:assertEquals("3r1nz")
function titemt:get-facsimile-uri-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:get-facsimile-uri-for-page($manifest-uri, $page)
};

declare
    %test:args("ahiqar_agg") %test:assertEquals("Arabic, Classical Syriac, Eastern Syriac, Karshuni, Western Syriac")
function titemt:get-language-string($manifest-uri as xs:string)
as xs:string {
    tapi-item:get-language-string($manifest-uri)
};

declare
    %test:args("ahiqar_agg", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/3r1nz")
function titemt:make-facsimile-id($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:make-facsimile-id($manifest-uri, $page, $tc:server)
};

declare
    %test:args("ahiqar_agg") %test:assertEquals("The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh")
function titemt:make-title($manifest-uri as xs:string)
as xs:string {
    tapi-item:make-title($manifest-uri)
};


declare
    %test:args("ahiqar_collection", "ahiqar_agg", "82a")
    (: checks if the correct file has been opened :)
    %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh' ")
    (: checks if language assembling works correctly :)
    %test:assertXPath("$result//*[local-name(.) = 'lang'] = 'syc' ")
    %test:assertXPath("$result//*[local-name(.) = 'langAlt'] = 'karshuni' ")
    %test:assertXPath("$result//*[local-name(.) = 'x-langString'][matches(., 'Classical Syriac')]")
    (: checks if underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'content'] = 'http://0.0.0.0:8080/exist/restxq/api/content/ahiqar_sample-82a.html' ")
    (: checks if images connected to underlying pages are identified :)
    %test:assertXPath("$result//*[local-name(.) = 'id'] = 'http://0.0.0.0:8080/exist/restxq/api/images/3r1nz' ")
function titemt:get-json($collection as xs:string,
    $document as xs:string,
    $page as xs:string) 
as element(object){
    tapi-item:get-json($collection, $document, $page, $tc:server)
};


declare
    %test:args("ahiqar_agg") %test:assertXPath("count($result) = 5")
    %test:args("ahiqar_agg") %test:assertXPath("$result[local-name(.) = ('lang', 'langAlt')]")
    %test:args("ahiqar_agg") %test:assertXPath("count($result[local-name(.) = 'lang']) = 2")
function titemt:make-language-elements($manifest-uri as xs:string) {
    tapi-item:make-language-elements($manifest-uri)
};