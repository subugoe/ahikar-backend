xquery version "3.1";

module namespace vars="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";

declare function vars:get-variants($teixml-uri as xs:string,
    $page as xs:string)
as map()* {
    let $tokens-on-page := vars:get-token-ids-on-page($teixml-uri, $page)
    return
        ()
};

declare function vars:get-token-ids-on-page($teixml-uri as xs:string,
    $page as xs:string)
as xs:string+ {
    let $page-chunks := vars:get-page-chunks($teixml-uri, $page)
    return
        $page-chunks//tei:w/@id
};

declare function vars:get-page-chunks($teixml-uri as xs:string,
    $page as xs:string)
as element(tei:TEI)+ {
    let $xml-doc := commons:open-tei-xml($teixml-uri)
    let $langs := $xml-doc//tei:text[@xml:lang[. = ("syc", "ara", "karshuni")]]/@xml:lang/string()
    return
        if ($langs = "karshuni") then
            (commons:get-page-fragment-from-uri($teixml-uri, $page, "transcription"),
            commons:get-page-fragment-from-uri($teixml-uri, $page, "transliteration"))
        else
            commons:get-page-fragment-from-uri($teixml-uri, $page, "transcription")
};

declare function vars:determine-sigil-position($sigil as xs:string,
    $json as map(*)) {
    let $witnesses := map:get($json, "witnesses")
    return
        index-of($witnesses?*, $sigil)
};