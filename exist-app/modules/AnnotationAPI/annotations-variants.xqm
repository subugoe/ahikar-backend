xquery version "3.1";

module namespace vars="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";

declare function vars:get-variants($teixml-uri as xs:string,
    $page as xs:string)
(:as map()* {:)
{
    let $tokens-on-page := vars:get-token-ids-on-page($teixml-uri, $page)
    let $idno := vars:determine-idno($teixml-uri)
    let $relevant-files := vars:get-relevant-files($idno)
    let $idno-pos := vars:determine-id-position($idno, $relevant-files[1])
    let $sigil := map:get($commons:idno-to-sigils-map, $idno)
    return
        $tokens-on-page
};

declare function vars:get-token-ids-on-page($teixml-uri as xs:string,
    $page as xs:string)
as xs:string+ {
    let $page-chunks := commons:get-transcription-and-transliteration-per-page($teixml-uri, $page)
    return
        $page-chunks//tei:w/@xml:id
};

declare function vars:determine-idno($teixml-uri as xs:string)
as xs:string {
    let $TEI := commons:open-tei-xml($teixml-uri)//tei:TEI
    return
        commons:make-id-from-idno($TEI)
};

declare function vars:determine-id-position($idno as xs:string,
    $json as map(*))
as xs:integer {
    let $witnesses := map:get($json, "witnesses")
    return
        index-of($witnesses?*, $idno)
};

declare function vars:get-relevant-files($idno as xs:string)
as item()+ {
    let $collation-collection := collection("/db/apps/ahikar/data/collation-results")
    let $relevant-base-uris :=
        for $doc in $collation-collection return
            if(matches(base-uri($doc), replace($idno, "/", "")) 
            and matches(base-uri($doc), "json")) then
                base-uri($doc)
            else
                ()
    for $uri in $relevant-base-uris return
        util:binary-doc($uri)
        => util:base64-decode()
        => parse-json()
};
