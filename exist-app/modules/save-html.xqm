xquery version "3.1";

module namespace sh="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/save";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "/db/apps/ahikar/modules/commons.xqm";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0.1/functx/functx.xq";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "/db/apps/ahikar/modules/tapi-html.xqm";

declare function sh:prepare-unit-tests($fragments as map(*))
as item()+ {
    let $uris :=
        for $uri in xmldb:get-child-resources($commons:data)[ends-with(., ".xml")] return
            $commons:data || $uri
    
    for $uri in $uris return
        sh:save-html($uri, $fragments)
};


declare function sh:save-html($teixml-uri as xs:string,
    $fragments as map(*)) {
    util:log("INFO", "Recreate HTML files for TEI file " || $teixml-uri),
    let $text-types := map:keys($fragments)
    for $type in $text-types return
        for $page in map:get($fragments, $type) => map:keys() return
            let $page-fragment :=
                map:get($fragments, $type)
                => map:get($page)
            let $html := tapi-html:get-html($teixml-uri, $page, $page-fragment)
            let $filename := sh:make-filename($teixml-uri, $page, $type)
            let $store := xmldb:store($commons:html, $filename, $html)
            return
                util:log("INFO", "Stored HTML files for TEI file " || $teixml-uri || ", page " || $page)
};

declare function sh:make-filename($teixml-uri as xs:string,
    $page as xs:string,
    $type as xs:string)
as xs:string {
    $teixml-uri || "-" || commons:format-page-number($page) || "-" || $type || ".html"
};
