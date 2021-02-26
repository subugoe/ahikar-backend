xquery version "3.1";

module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace functx="http://www.functx.com";
import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "tokenize.xqm";


declare variable $tei2json:textgrid := "/db/data/textgrid";
declare variable $tei2json:data := $tei2json:textgrid || "/data";
declare variable $tei2json:json := $tei2json:textgrid || "/json";
declare variable $tei2json:milestone-types :=
    ("first_narrative_section",
    "sayings",
    "second_narrative_section",
    "parables",
    "third_narrative_section");
declare variable $tei2json:lines-of-transmission :=
    [
        (
            "Sachau 336",
            "433"
        ),
        (
            "Ar 7/229",
            "Sachau 162", 
            "162",
            "Or. 2313", 
            "Add. 7200", 
            "Add. 2020",
            "Sado no. 9",
            "Manuscrit 4122",
            "Syr 80"
        ),
        (
            "syr. 434",
            "syr. 422",
            "430",
            "syr. 612", 
            "syr. 611",
            "Unknown"
        )
    ];

declare function tei2json:main()
as xs:string+ {
    let $prepare := tei2json:create-json-collection-if-not-available()
    let $tokenized-teis := tei2json:tokenize-teis()
    return
        tei2json:make-collation-per-section($tokenized-teis)
};


declare function tei2json:create-json-collection-if-not-available()
as xs:string? {
    if (xmldb:collection-available($tei2json:json)) then
        ()
    else
        xmldb:create-collection($tei2json:textgrid, "json")
};


declare function tei2json:tokenize-teis() {
    let $teis := tei2json:get-teis()
    for $tei in $teis return
        tokenize:main($tei)
};


declare function tei2json:get-teis() {
    collection($tei2json:data)//tei:TEI
};


declare function tei2json:make-collation-per-section($tokenized-teis as element(tei:TEI)+)
as xs:string+ {
    for $milestone-type in $tei2json:milestone-types return
        for $language in ("syc", "ara", "karshuni") return
            let $json := map {
                "witnesses":
                    array {
                        for $text in tei2json:get-texts-per-language($tokenized-teis, $language) return
                            tei2json:make-json-per-section($text, $milestone-type)
                    }
            }
        let $json-string := serialize($json, map{ "method": "json" })
        return
            xmldb:store-as-binary($tei2json:json, concat($language, "_", $milestone-type, ".json"), $json-string)
};

declare function tei2json:get-texts-per-language($tokenized-teis as element(tei:TEI)+,
    $language as xs:string)
as element(tei:text)* {
    switch ($language)
        case "karshuni" return
            $tokenized-teis//tei:text[@xml:lang = "ara" and @type = "transliteration"][tei2json:has-text-milestone(.)]
        default return
            $tokenized-teis//tei:text[@xml:lang = $language and @type = "transcription"][tei2json:has-text-milestone(.)]
};

declare function tei2json:get-texts-per-line-of-transmission($tokenized-teis as element(tei:TEI)+,
    $language as xs:string,
    $line as xs:string+)
as element(tei:text) {
    switch ($language)
        case "karshuni" return
            $tokenized-teis[descendant::tei:msIdentifier/tei:idno = $line]//tei:text[@xml:lang = "ara" and @type = "transliteration"][tei2json:has-text-milestone(.)]
        default return
            $tokenized-teis[descendant::tei:msIdentifier/tei:idno = $line]//tei:text[@xml:lang = $language and @type = "transcription"][tei2json:has-text-milestone(.)]
};


declare function tei2json:has-text-milestone($text as element(tei:text))
as xs:boolean {
    exists($text//tei:milestone[@unit = $tei2json:milestone-types])
};


declare function tei2json:get-chunk($text as element(tei:text),
    $milestone-type as xs:string)
as element(tei:TEI) {
    let $root := $text/root()
    let $milestone := $text//tei:milestone[@unit = $milestone-type]
    return
        if (exists($milestone)) then
            let $end-of-chunk := tei2json:get-end-of-chunk($milestone)
            return
                fragment:get-fragment-from-doc(
                    $root,
                    $milestone,
                    $end-of-chunk,
                    false(),
                    true(),
                    (""))
        else
            element {QName("http://www.tei-c.org/ns/1.0", "TEI")} {text{" "}}
};


declare function tei2json:get-end-of-chunk($milestone as element(tei:milestone))
as element() {
    if (tei2json:has-following-milestone($milestone)) then 
        tei2json:get-next-milestone($milestone)
    else
        $milestone/ancestor::tei:text[1]/tei:body/child::*[last()]
};


declare function tei2json:has-following-milestone($milestone as element(tei:milestone))
as xs:boolean {
    exists($milestone/following::*[local-name(.) = 'milestone'][./ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]])
};


declare function tei2json:get-next-milestone($milestone as element(tei:milestone))
as element(tei:milestone)? {
    $milestone/following::*[local-name(.) = 'milestone'][./ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]][1]
};

declare function tei2json:make-json-per-section($text as element(tei:text),
    $milestone-type as xs:string) {
    let $chunk := tei2json:get-chunk($text, $milestone-type)
    (: only the relevant next nodes have been tokenized, so no need for filtering
    them again. :)
    let $tokens := $chunk//tei:w
    return
        tei2json:make-map-per-witness($tokens)
};


declare function tei2json:make-map-per-witness($tokens as element(tei:w)*)
as map() {
    let $witness-id := $text/ancestor::tei:TEI//tei:msIdentifier/tei:idno/string()
    
    return
        map {
            "id": $witness-id,
            "tokens":
                array {
                    if ($tokens) then
                        for $t in $tokens return
                            map {
                                "t": $t/string(),
                                "id": $t/@xml:id/string()
                            }
                    else
                        map {
                            "t": "omisit"
                        }
                }
        }
};
