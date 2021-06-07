xquery version "3.1";

module namespace sh="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/save";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "/db/apps/ahikar/modules/commons.xqm";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0.1/functx/functx.xq";
import module namespace rest="http://exquery.org/ns/restxq";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "/db/apps/ahikar/modules/tapi-html.xqm";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/html/save")
    %rest:query-param("token", "{$token}")
function sh:main($token) {
    if( $token ne environment-variable("APP_DEPLOY_TOKEN" )) then
        error(QName("error://1", "deploy"), "Deploy token incorrect.")
    else
        (
            if (xmldb:collection-available($commons:html)) then
                    ()
                else
                    xmldb:create-collection("/db/data/textgrid", "html"),
            let $uris :=
                for $doc in collection($commons:data)[ends-with(base-uri(.), ".xml")] return
                    base-uri($doc)
            
            for $uri in $uris return
                sh:save-html($uri)
        )
            
};


declare function sh:save-html($uri as xs:string) {
    let $log := util:log-system-out("Recreate HTML files for TEI file " || $uri)
    let $make-html-coll :=
        if (xmldb:collection-available($commons:html)) then
            ()
        else
            xmldb:create-collection("/db/data/textgrid", "html")

    let $teixml-uri := local:extract-uri-from-base-uri($uri)
    let $text-types := commons:get-text-types($teixml-uri)
    for $type in $text-types return
        for $page in commons:get-pages-for-text-type($teixml-uri, $type) return
        let $html := tapi-html:get-html($teixml-uri, $page, $type)
        let $filename := sh:make-filename($teixml-uri, $page, $type)
        let $store := xmldb:store($commons:html, $filename, $html)
        return
            util:log-system-out("Stored HTML files for TEI file " || $uri)
};

declare function local:extract-uri-from-base-uri($base-uri as xs:string) {
    functx:substring-after-last($base-uri, "/")
    => substring-before(".xml")
};

declare function sh:make-filename($teixml-uri as xs:string,
    $page as xs:string,
    $type as xs:string)
as xs:string {
    $teixml-uri || "-" || commons:format-page-number($page) || "-" || $type || ".html"
};
