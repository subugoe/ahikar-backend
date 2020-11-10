xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tapi/images/tests";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-img="http://ahikar.sub.uni-goettingen.de/ns/tapi/images" at "../modules/tapi-img.xqm";

declare
    %test:args("ahiqar_agg")
    %test:assertTrue
function t:has-manifest-tile($manifest-uri) as xs:boolean {
    tapi-img:has-manifest-tile($manifest-uri)
};

declare
    %test:args("ahiqar_sample") %test:assertFalse
    %test:args("ahiqar_tile") %test:assertTrue
function t:is-resource-tile($uri) as xs:boolean {
    tapi-img:is-resource-tile($uri)
};

declare
    %test:args("ahiqar_tile") %test:assertTrue
    %test:args("ahiqar_tile-non-existent") %test:assertFalse
function t:is-tile-available($tile-uri as xs:string)
as xs:boolean {
    tapi-img:is-tile-available($tile-uri)
};

declare
    %test:args("ahiqar_agg") %test:assertEquals("ahiqar_tile")
function t:get-tile-uris($manifest-uri as xs:string)
as xs:string {
    tapi-img:get-tile-uris($manifest-uri)
};

declare
    %test:args("ahiqar_tile") %test:assertXPath("$result//*[local-name(.) = 'rect']")
function t:get-tile($uri as xs:string)
as document-node() {
    tapi-img:get-tile($uri)
};