xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests/credentials";

declare namespace http = "http://expath.org/ns/http-client";

import module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons" at "test-commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-item="http://ahikar.sub.uni-goettingen.de/ns/tapi/item" at "../modules/tapi-item.xqm";
import module namespace titemt="http://ahikar.sub.uni-goettingen.de/ns/tapi/item/tests" at "tapi-item-tests.xqm";

declare
    %test:setUp
function t:_test-setup() {
    titemt:create-and-store-test-data()
};


declare
    %test:tearDown
function t:_test-teardown() {
    titemt:remove-test-data()
};


declare
    %test:args("sample_edition", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/restricted/3r1nz/50.03,0.48,49.83,100.00")
    (: the following file is test data created by setUp :)
    %test:args("ahiqar_agg_wo_tile", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/restricted/3r1nz")
function t:make-facsimile-id($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:make-facsimile-id($manifest-uri, $page, $tc:server)
};

declare
    %test:args("3qzg5") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/public/3qzg5")
    %test:args("3r1nz") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/restricted/3r1nz")
    %test:assumeInternetAccess("https://textgridlab.org/1.0/tgcrud-public/rest/")
function t:make-img-url-prefix($facsimile-uri as xs:string)
as xs:string {
    tapi-item:make-img-url-prefix($facsimile-uri, $tc:server)
};

declare
    %test:args("3qzg5") %test:assertEquals("public/")
    %test:args("3r1nz") %test:assertEquals("restricted/")
    %test:assumeInternetAccess("https://textgridlab.org/1.0/tgcrud-public/rest/")
function t:make-restricted-or-public-path-component($facsimile-uri as xs:string)
as xs:string {
    tapi-item:make-restricted-or-public-path-component($facsimile-uri)
};

declare
    %test:args("3r1nz") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/restricted/3r1nz")
function t:make-url-for-single-page-image($facsimile-uri as xs:string)
as xs:string {
    tapi-item:make-url-for-single-page-image($facsimile-uri, $tc:server)
};

declare
    %test:args("3r1nz", "sample_edition", "82a") %test:assertEquals("http://0.0.0.0:8080/exist/restxq/api/images/restricted/3r1nz/50.03,0.48,49.83,100.00")
function t:make-url-for-double-page-image($facsimile-uri as xs:string,
    $manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    tapi-item:make-url-for-double-page-image($facsimile-uri, $manifest-uri, $page, $tc:server)
};