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
    let $page-chunks := commons:get-transcription-and-transliteration-per-page($teixml-uri, $page)
    return
        $page-chunks//tei:w/@id
};

declare function vars:determine-sigil-position($sigil as xs:string,
    $json as map(*)) {
    let $witnesses := map:get($json, "witnesses")
    return
        index-of($witnesses?*, $sigil)
};
