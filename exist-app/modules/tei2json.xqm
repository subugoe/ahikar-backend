xquery version "3.1";

module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace functx="http://www.functx.com";
import module namespace norm="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization" at "tapi-txt-normalization.xqm";
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
        [
            "Sachau 336",
            "433"
        ],
        [
            "Ar 7/229",
            "Sachau 162", 
            "162",
            "Or. 2313", 
            "Add. 7200", 
            "Add. 2020",
            "Sado no. 9",
            "Manuscrit 4122",
            "Syr 80"
        ],
        [
            "syr. 434",
            "syr. 422",
            "430",
            "syr. 612", 
            "syr. 611",
            "Unknown"
        ],
        [
            "Sbath 25",
            "Vat. sir. 424", 
            "Vat. sir. 199"
        ],
        [
            "Vat. ar. 74 (Scandar 40)"
        ],
        [
            "Brit. Mus. Add. 7209", 
            "Vat. sir. 159", 
            "Mingana Syr. 258", 
            "Cod. Arab. 236", 
            "DFM 00614", 
            "Sachau 290 (=Sachau 339)", 
            "Brit. Libr. Or. 9321"
        ],
        [
            "Paris. Arabe 3637", 
            "Paris Arabe 3656", 
            "Camb. Add. 2886", 
            "Mingana ar. christ. 93[84]", 
            "Mingana syr. 133", 
            "Vat. ar. 2054", 
            "GCAA 00486", 
            "Salhani", 
            "Borg. ar. 201", 
            "Or. 1292b", 
            "Gotha 2652", 
            "Cambrigde Add. 3497"
        ]
    ];

declare function tei2json:main()
as xs:string+ {
    let $prepare := tei2json:create-json-collection-if-not-available()
    let $tokenized-teis := tei2json:tokenize-teis()
    return
        tei2json:make-jsons-per-section-and-transmission-line($tokenized-teis)
};


declare function tei2json:create-json-collection-if-not-available()
as xs:string? {
    if (xmldb:collection-available($tei2json:json)) then
        ()
    else
        xmldb:create-collection($tei2json:textgrid, "json")
};


declare function tei2json:tokenize-teis()
as element(tei:TEI) {
    let $teis := tei2json:get-teis()
    for $tei in $teis return
        tokenize:main($tei)
};


declare function tei2json:get-teis()
as element(tei:TEI)* {
    collection($tei2json:data)//tei:TEI
};


declare function tei2json:make-jsons-per-section-and-transmission-line($tokenized-teis as element(tei:TEI)+)
as xs:string+ {
    let $no-of-lines-of-transmission := array:size($tei2json:lines-of-transmission)
    for $iii in 1 to $no-of-lines-of-transmission return
        let $language :=
            if ($iii lt 4) then
                "syc"
            else
                "ara-karshuni"
        for $milestone-type in $tei2json:milestone-types return
            let $json := map {
                "witnesses":
                    array {
                        let $manuscripts-of-line := array:get($tei2json:lines-of-transmission, $iii)
                        let $no-of-manuscripts := array:size($manuscripts-of-line)
                        for $jjj in 1 to $no-of-manuscripts return
                            let $manuscript-id := array:get($manuscripts-of-line, $jjj)
                        
                            for $text in tei2json:get-relevant-text($tokenized-teis, $manuscript-id) return
                                tei2json:make-json-per-section($text, $milestone-type)
                    }
            }
            
            let $json-string := serialize($json, map{ "method": "json" })
            let $transmission-string := 
                array:get($tei2json:lines-of-transmission, $iii)
                => string-join("_")
                => replace(" ", "-")
                => replace("[\(\)=\[\]]", "")
            let $filename := concat($language, "_", $transmission-string, "_", $milestone-type, ".json")
            return
                xmldb:store-as-binary($tei2json:json, $filename, $json-string)
};

declare function tei2json:get-relevant-text($tokenized-teis as element(tei:TEI)+,
    $id as xs:string)
as element(tei:text)* {
    let $relevant-text := $tokenized-teis[descendant::tei:msIdentifier/tei:idno = $id or matches(descendant::tei:editor, $id)]
    let $texts-with-milestone := $relevant-text//tei:text[tei2json:has-text-milestone(.)]
    return
        (: karshuni :)
        if ($texts-with-milestone[@xml:lang = "ara" and @type = "transliteration"]) then
            $texts-with-milestone[@xml:lang = "ara" and @type = "transliteration"]
        (: arabic + syriac :)
        else
            $texts-with-milestone[@type = "transcription"]
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
    $milestone-type as xs:string)
as map() {
    let $chunk := tei2json:get-chunk($text, $milestone-type)
    (: only the relevant next nodes have been tokenized, so no need for filtering
    them again. :)
    let $tokens := $chunk//tei:w
    let $witness-id := $text/ancestor::tei:TEI//tei:msIdentifier/tei:idno/string()
    return
        tei2json:make-map-per-witness($witness-id, $tokens)
};


declare function tei2json:make-map-per-witness($witness-id as xs:string,
    $tokens as element(tei:w)*)
as map() {
    map {
        "id": $witness-id,
        "tokens":
            array {
                if ($tokens) then
                    for $t in $tokens return
                        map {
                            "t": norm:get-txt-without-diacritics($t/string())
                                => replace("[^a-zA-Z0-9]", "_")
                                => replace("[_]+", "_"),
                            "id": $t/@xml:id/string()
                        }
                else
                    map {
                        "t": "omisit"
                    }
            }
    }
};

declare function tei2json:compress-to-zip()
as xs:base64Binary* {
    compression:zip(xs:anyURI($tei2json:json), false())
};
