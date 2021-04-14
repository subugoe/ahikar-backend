xquery version "3.1";

module namespace vars="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";
import module namespace functx = "http://www.functx.com";

declare variable $vars:ns := "http://ahikar.sub.uni-goettingen.de/ns/annotations";

declare function vars:get-variants($teixml-uri as xs:string,
    $page as xs:string)
as map(*)* {
    let $variants := vars:get-variants-on-page-as-maps($teixml-uri, $page)
    
    for $map in $variants
        let $id := map:get($map, "current") => map:get("id")
        return
            map {
                "id": $vars:ns || "/" || $teixml-uri || "/annotation-variants-" || $id,
                "type": "Annotation",
                "body": vars:get-body-object($map),
                "target": vars:get-target-information($map, $teixml-uri, $id)
            }
};

declare function vars:get-body-object($map as map(*))
as map() {
    map {
        "type": "TextualBody",
        "value": vars:make-annotation-value($map),
        "format": "text/plain",
        "x-content-type": "Variant"
    }
};

declare function vars:make-annotation-value($map as map(*))
as map(*)+ {
    for $variant in map:get($map, "variants") return
        let $entry := map:get($variant, "entry") 
        let $witness := map:get($variant, "witness")
        return
            map {
                "entry": if ($entry instance of xs:string) then $entry else "omisit",
                "witness": map:get($commons:idno-to-sigils-map, $witness)
            }
};

declare function vars:get-target-information($map as map(*),
    $teixml-uri as xs:string,
    $id as xs:string)
as map(*) {
    map {
        "id": $vars:ns || "/" || $teixml-uri || "/"|| $id,
        "format": "text/xml",
        "language": vars:get-target-language($teixml-uri)
    }
};

declare function vars:get-target-language($teixml-uri as xs:string)
as xs:string {
    let $doc := commons:open-tei-xml($teixml-uri)
    let $language := $doc//tei:text[@xml:lang][matches(descendant::text(), "[\w]")]/@xml:lang
    return
        $language
};

(:~
 : Returns a map holding the current token as well as all its resp. variants per
 : page. The exact value of the current token depends on the manuscript we are
 : currently looking at.
 : 
 : @param $teixml-uri The current TEI document's base URI, e.g. "12345"
 : @param $page The page as given in tei:pb/@n
 : @return A map with information about the current token and its variants 
 :)
declare function vars:get-variants-on-page-as-maps($teixml-uri as xs:string,
    $page as xs:string)
as map()* {
    let $ms-id := vars:get-ms-id-from-idno($teixml-uri)
    let $relevant-files-for-ms-id := vars:get-relevant-files($ms-id)
    (: the MS identifier position is the same in all relevant files, so we simply
    choose the first for looking it up :)
    let $ms-id-position := vars:determine-id-position($ms-id, $relevant-files-for-ms-id[1])
    let $tokens := vars:get-token-ids-on-page($teixml-uri, $page)
    let $files-relevant-for-page := vars:get-files-relevant-for-page($relevant-files-for-ms-id, $ms-id-position, $tokens)
    
    for $file in $files-relevant-for-page return
        let $table := map:get($file, "table")
        let $no-of-sequence := array:size($table)
        let $indices-relevant-for-page := vars:get-indices-relevant-for-page($table, $no-of-sequence, $ms-id-position, $tokens)
        let $non-ms-id-positions := vars:get-non-ms-id-positions-in-array($file, $ms-id-position)
        
        for $iii in $indices-relevant-for-page return
            vars:make-map-for-token($file, $table, $iii, $ms-id-position, $non-ms-id-positions)
};


(:~ 
 : Each token (= relevant word) is encoded in a tei:w which has an @xml:id
 : attribute.
 : 
 : @param $teixml-uri The base URI of the document, e.g. "12345"
 : @param $page The current page as provided in tei:pb/@n
 :)
declare function vars:get-token-ids-on-page($teixml-uri as xs:string,
    $page as xs:string)
as xs:string+ {
    let $page-chunks := commons:get-transcription-and-transliteration-per-page($teixml-uri, $page)
    return
        $page-chunks//tei:w/@xml:id
};

declare function vars:get-ms-id-from-idno($teixml-uri as xs:string)
as xs:string {
    let $TEI := commons:open-tei-xml($teixml-uri)//tei:TEI
    return
        commons:make-id-from-idno($TEI)
};

(:~
 : In the CollateX results, we first have an aray of witnesses before the result
 : of the collation is given in the JSON file. The position of a MS identifier
 : in this array is reflected in the collation result; The witness on position 2
 : will always have its tokens in the second position of the result.
 : 
 : @param $ms-id The MS identifier as given in the array of witnesses
 : @param $json The collation result as JSON
 : @return The position of the current MS identifier in the witnesses array
 :)
declare function vars:determine-id-position($ms-id as xs:string,
    $json as map(*))
as xs:integer {
    let $witnesses := map:get($json, "witnesses")
    return
        index-of($witnesses?*, $ms-id)
};

declare function vars:get-relevant-files($ms-id as xs:string)
as item()+ {
    let $collation-collection := collection("/db/apps/ahikar/data/collation-results")
    let $relevant-base-uris :=
        for $doc in $collation-collection return
            if(matches(base-uri($doc), replace($ms-id, "/", "")) 
            and matches(base-uri($doc), "json")) then
                base-uri($doc)
            else
                ()
    for $uri in $relevant-base-uris return
        util:binary-doc($uri)
        => util:base64-decode()
        => parse-json()
};


declare function vars:get-files-relevant-for-page($relevant-files-for-ms-id as map()+,
    $ms-id-position as xs:integer,
    $tokens as xs:string+)
as map()+ {
    let $first-token := $tokens[1]
    let $last-token := $tokens[last()]
    for $file in $relevant-files-for-ms-id return
        let $table := map:get($file, "table")
        let $no-of-sequences := array:size($table)
        for $iii in 1 to $no-of-sequences return
            let $sequence-entry := $table?($iii)
            let $ms-id-entry := $sequence-entry?($ms-id-position)
            let $this-manuscripts-ids :=
                if (array:size($ms-id-entry) gt 0) then
                    $ms-id-entry?(1)
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

declare function vars:get-non-ms-id-positions-in-array($file as map(),
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
    $entry-no as xs:integer,
    $witness-position as xs:integer)
as array(*) {
    let $sequence-entry := $table?($entry-no)
    return
        $sequence-entry?($witness-position)
};

(:~
 : Returns a sequence of index positions that are relevant for the current witness.
 : If a witness doesn't have an entry in the collation result or if the entry is
 : not on the current page, no index position is returned.
 : 
 : @param $table The CollateX results
 : @param $no-of-sequences The number of result sequences in $table
 : @param $ms-id-position An integer determining which position within the result entry is relevant for the current witness
 : @param $tokens A list of tokens relevant for the current page
 :)
declare function vars:get-indices-relevant-for-page($table as array(*),
    $no-of-sequences as xs:integer,
    $ms-id-position as xs:integer,
    $tokens as xs:string+)
as xs:integer+ {
    for $iii in 1 to $no-of-sequences return
        let $sequence-entry := $table?($iii)
        let $ms-id-entry := $sequence-entry?($ms-id-position)
        return
            if (array:size($ms-id-entry) gt 0
            and array:get($ms-id-entry, 1) => map:get("id") = $tokens) then
                $iii
            else
                ()
};

(:~
 : Creates a map in for every token on a page in which all variants are listed.
 :
 : @param $table The CollateX results
 : @param $no-of-sequences The number of result sequences in $table
 : @param $ms-id-position An integer determining which position within the result entry is relevant for the current witness
 : @param $tokens A list of tokens relevant for the current page
 :)
declare function vars:make-map-for-token($file as map(),
    $table as array(*),
    $entry-pos as xs:integer,
    $ms-id-position as xs:integer,
    $non-ms-id-positions as xs:integer*)
as map(*) {
    let $sequence-entry := $table?($entry-pos)
    let $ms-id-entry := $sequence-entry?($ms-id-position)
    let $tokens-in-sequence := array:size($ms-id-entry)
    for $token-no in $tokens-in-sequence return
        map {
            "current": $sequence-entry?($ms-id-position) => array:get($token-no),
            "variants":
                for $jjj in $non-ms-id-positions return
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
