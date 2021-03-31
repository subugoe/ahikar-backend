xquery version "3.1";

module namespace vars="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";
import module namespace functx = "http://www.functx.com";

declare function vars:get-variants($teixml-uri as xs:string,
    $page as xs:string)
as map()* {
    let $tokens := vars:get-token-ids-on-page($teixml-uri, $page)
    
    let $idno := vars:determine-idno($teixml-uri)
    let $relevant-files-for-idno := vars:get-relevant-files($idno)
    
    let $idno-position := vars:determine-id-position($idno, $relevant-files-for-idno[1])
    
    let $files-relevant-for-page := vars:get-files-relevant-for-page($relevant-files-for-idno, $idno-position, $tokens)
    
    for $file in $files-relevant-for-page return
        let $table := map:get($file, "table")
        let $sequence-no := array:size($table)
        let $indices-relevant-for-page := vars:get-indices-relevant-for-page($table, $sequence-no, $idno-position, $tokens)
        let $non-idno-positions := vars:get-non-idno-positions-in-array($file, $idno-position)
        
        for $iii in $indices-relevant-for-page return
            vars:make-map-for-token($file, $table, $iii, $sequence-no, $idno-position, $non-idno-positions)
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

declare function vars:determine-files-relevant-for-tokens($idno as xs:string,
    $tokens as xs:string+) {
    let $files-relevant-for-idno := vars:get-relevant-files($idno)
    for $file in $files-relevant-for-idno return
        for $t in $tokens return
            commons:find-in-map($file, $t)
};

declare function vars:get-files-relevant-for-page($relevant-files-for-idno as map()+,
    $idno-position as xs:integer,
    $tokens as xs:string+)
as map()+ {
    let $first-token := $tokens[1]
    let $last-token := $tokens[last()]
    for $file in $relevant-files-for-idno return
        let $table := map:get($file, "table")
        let $sequence-no := array:size($table)
        for $iii in 1 to $sequence-no return
            let $sequence-entry := $table?($iii)
            let $idno-entry := $sequence-entry?($idno-position)
            let $this-manuscripts-ids :=
                if (array:size($idno-entry) gt 0) then
                    $idno-entry?(1)
                    => map:get("id")
                else
                    ()
            return
                if ($this-manuscripts-ids = ($first-token, $last-token)) then
                    $file
                else
                    ()
};

declare function vars:get-witness($file as map(),
    $witness-position as xs:integer)
as xs:string {
    map:get($file, "witnesses")
    => array:get($witness-position)
};

declare function vars:get-non-idno-positions-in-array($file as map(),
    $witness-position as xs:integer)
as xs:integer+ {
    let $no-of-witnesses := map:get($file, "witnesses") => array:size()
    let $no-of-witnesses-as-sequence :=
        for $iii in 1 to $no-of-witnesses return
            $iii
    return
        functx:value-except($no-of-witnesses-as-sequence, $witness-position)
};

declare function vars:get-witness-entry($table as array(*),
    $entry-no as xs:string,
    $witness-position as xs:string)
as array(*) {
    let $sequence-entry := $table?($entry-no)
    return
        $sequence-entry?($witness-position)
};

declare function vars:get-indices-relevant-for-page($table as array(*),
    $sequence-no as xs:integer,
    $idno-position as xs:integer,
    $tokens as xs:string+)
as xs:integer* {
    for $iii in 1 to $sequence-no return
        let $sequence-entry := $table?($iii)
        let $idno-entry := $sequence-entry?($idno-position)
        return
            if (array:size($idno-entry) gt 0
            and array:get($idno-entry, 1) => map:get("id") = $tokens) then
                $iii
            else
                ()
};

declare function vars:make-map-for-token($file as map(),
    $table as array(*),
    $entry-pos as xs:integer,
    $sequence-no as xs:integer,
    $idno-position as xs:integer,
    $non-idno-positions as xs:integer*)
as map(*) {
    let $sequence-entry := $table?($entry-pos)
    let $idno-entry := $sequence-entry?($idno-position)
    let $tokens-in-sequence := array:size($idno-entry)
    for $token-no in $tokens-in-sequence return
        map {
            "current": $sequence-entry?($idno-position) => array:get($token-no),
            "variants":
                for $jjj in $non-idno-positions return
                    map {
                        "witness": vars:get-witness($file, $jjj),
                        "entry": 
                            if ($sequence-entry?($jjj) => array:size() ge $token-no) then
                                $sequence-entry?($jjj) => array:get($token-no) => map:get("t")
                            else
                                []
                    }
        }
};
