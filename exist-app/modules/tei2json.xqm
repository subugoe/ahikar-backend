xquery version "3.1";

(:~
 : This module is responsible for creating the JSON files we need for collating.
 : For this, the different lines of transmission as well as the semantic sections of the texts are considered:
 : For each line of transmission 5 files (one for each semantic section/milestone type) is generated.
 :
 : The end result has the following form:
 :
 :{
 :  "witnesses" : [
 :    {
 :      "id" : "A",
 :      "tokens" : [
 :          { "t" : "A", "id" : "x1" },
 :          { "t" : "black" , "id" : "x2" },
 :          { "t" : "cat", "id" : "x3" }
 :      ]
 :    },
 :    {
 :      "id" : "B",
 :      "tokens" : [
 :          { "t" : "A", "id": "y1" },
 :          { "t" : "white" , "id" : "y2 },
 :          { "t" : "kitten.", "id" : "y3" }
 :      ]
 :    }
 :  ]
 :}
 :)

module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace norm="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization" at "tapi-txt-normalization.xqm";
import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "tokenize.xqm";


declare variable $tei2json:milestone-types :=
    ("first_narrative_section",
    "sayings",
    "second_narrative_section",
    "parables",
    "third_narrative_section");
declare variable $tei2json:lines-of-transmission :=
    [
        [
            "Sachau_336",
            "433"
        ],
        [
            "Ar_7229",
            "Sachau_162", 
            "162",
            "Or_2313", 
            "Add_7200", 
            "Add_2020",
            "Sado_no_9",
            "Manuscrit_4122",
            "Syr_80"
        ],
        [
            "syr_434",
            "syr_422",
            "430",
            "syr_612", 
            "syr_611",
            "Unknown"
        ],
        [
            "Sbath_25",
            "Vat_sir_424", 
            "Vat_sir_199"
        ],
        [
            "Vat_ar_74_Scandar_40"
        ],
        [
            "Brit_Mus_Add_7209", 
            "Vat_sir_159", 
            "Mingana_Syr_258", 
            "Cod_Arab_236", 
            "DFM_00614", 
            "Sachau_290_Sachau_339", 
            "Brit_Libr_Or_9321"
        ],
        [
            "Paris_Arabe_3637", 
            "Paris_Arabe_3656", 
            "Camb_Add_2886", 
            "Mingana_ar_christ_93_84", 
            "Mingana_syr_133", 
            "Vat_ar_2054", 
            "GCAA_00486", 
            "Salhani", 
            "Borg_ar_201", 
            "Or_1292b", 
            "Ms_orient_A_2652", 
            "Cambrigde_Add_3497"
        ]
    ];

declare function tei2json:main()
as xs:string+ {
    tei2json:remove-old-jsons(),
    tei2json:create-json-collection,
    tei2json:tokenize-teis()
    => tei2json:make-jsons-per-section-and-transmission-line()
};

declare function tei2json:remove-old-jsons()
as item() {
    xmldb:remove($commons:tg-collection || "/json")
};

declare function tei2json:create-json-collection()
as xs:string {
    xmldb:create-collection($commons:tg-collection, "json")
};


declare function tei2json:tokenize-teis()
as element(tei:TEI)+ {
    let $teis := tei2json:get-teis()
    for $tei in $teis return
        tokenize:main($tei)
};


declare function tei2json:get-teis()
as element(tei:TEI)* {
    collection($commons:data)[not(contains(base-uri(.), "sample"))]//tei:TEI
};


(:~
 : Since we don't collate the complete texts due to performance reasons, we
 : consider the narrative chunks specified by the milestones separately. This
 : consideration is the reason for the outmost loop.
 : 
 : Within a language we distinguish between different lines of transmission.
 : From a philological point of view it is sufficient to compare only the
 : manuscripts of a line of transmission while leaving out the rest. This is 
 : handled by the second loop.
 : 
 : The third loop retrieves the relevant text within a manuscript of the line of
 : transmission. 
 :)
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
                => replace("[^a-zA-Z0-9-_]", "")
            let $filename := concat($language, "_", $transmission-string, "_", $milestone-type, ".json")
            return
                xmldb:store-as-binary($commons:json, $filename, $json-string)
};

declare function tei2json:get-relevant-text($tokenized-teis as element(tei:TEI)+,
    $id as xs:string)
as element(tei:text)* {
    let $relevant-text := 
        for $tei in $tokenized-teis return
            let $idno := commons:make-id-from-idno($tei)
            return
                if ($idno = $id or matches($tei/descendant::tei:editor, $id)) then
                    $tei
                else
                    ()
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
    (: only the relevant next nodes have been tokenized and enclosed by a tei:w,
     : so no need for filtering them again. :)
    let $tokens := $chunk//tei:w
    let $witness-id := commons:make-id-from-idno($text/ancestor::tei:TEI)
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
                                => replace("[\.,\?]", "_")
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
