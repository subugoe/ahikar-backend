xquery version "3.1";

(:~
 : Test module for the RESTXQ endpoints of the Ahikar TextAPI.
 : 
 : @author Michelle Weidling
 : @version 0.1.0
 :)

module namespace tt="http://ahikar.sub.uni-goettingen.de/ns/tapi/tests/credentials";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare
    %test:assertTrue
function tt:is-item-endpoint-http200() {
    let $url := $tc:server || "/textapi/ahikar/syriac/sample_edition-82a/latest/item.json"
    return
        tc:is-endpoint-http200($url)
};

declare
    (: check if all parts are present.
     : no further tests are needed since the content has been tested while testing
     : the underlying function. :)
    %test:assertXPath("map:contains($result, 'textapi')")
    %test:assertXPath("map:contains($result, 'title')")
    %test:assertXPath("map:contains($result, 'type')")
    %test:assertXPath("map:contains($result, 'n')")
    %test:assertXPath("map:contains($result, 'content')")
    %test:assertXPath("map:contains($result, 'lang')")
    %test:assertXPath("map:contains($result, 'langAlt')")
    %test:assertXPath("map:contains($result, 'image')")
function tt:endpoint-item() as item() {
    let $url := $tc:server || "/textapi/ahikar/syriac/sample_edition-82a/latest/item.json"
    let $req := tc:make-request($url)
    return http:send-request($req)[2]
        => util:base64-decode()
        => parse-json()
};
