xquery version "3.1";

(:~
 : This module extracts the chunks marked as important for the collation from
 : the TEI files and uses them as an input for the plain text creation. These
 : serve as a basis for the collation with CollateX in the project's CI/CD
 : pipelines.
 :)

module namespace coll="http://ahikar.sub.uni-goettingen.de/ns/collate";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";

declare variable $coll:textgrid := "/db/apps/sade/textgrid";
declare variable $coll:data := $coll:textgrid || "/data";
declare variable $coll:txt := $coll:textgrid || "/txt";
declare variable $coll:milestone-types :=
    ("first_narrative_section",
    "sayings",
    "second_narrative_section",
    "parables",
    "third_narrative_section");


declare function coll:main() 
as xs:string+ {
    coll:create-txt-collection-if-not-available(),
    for $text in coll:get-transcriptions-and-transliterations() return
        for $milestone-type in $coll:milestone-types return
            let $relevant-text := coll:get-relevant-text($text)
            let $file-name := coll:make-file-name($text, $milestone-type)
            return
                xmldb:store($coll:txt, $file-name, $relevant-text, "text/plain")
};

declare function coll:create-txt-collection-if-not-available()
as xs:string? {
    if (xmldb:collection-available($coll:txt)) then
        ()
    else
        xmldb:create-collection($coll:textgrid, "txt")
};

declare function coll:get-transcriptions-and-transliterations()
as element(tei:text)+ {
    collection($coll:data)//tei:text[@type = ("transcription", "transliteration")]
        [coll:has-text-milestone(.)]
};

declare function coll:has-text-milestone($text as element(tei:text))
as xs:boolean {
    exists($text//tei:milestone)
};

(:~
 : An example for the file name is 
 : syriac-Brit_Lib_Add_7200-3r131-transcription.txt
 :)
declare function coll:make-file-name($text as element(tei:text),
    $milestone-type as xs:string)
as xs:string {
    let $lang-prefix := coll:get-language-prefix($text)
    let $title-from-metadata := coll:create-metadata-title-for-file-name($text)
    let $uri-text-type-milestone := coll:make-file-name-suffix($text, $milestone-type)
    return
        $lang-prefix || "-" || $title-from-metadata || "-" || $uri-text-type-milestone
};

declare function coll:get-language-prefix($text as element(tei:text))
as xs:string? {
    switch ($text/@type)
        case "transcription" return
            switch ($text/@xml:lang)
                case "karshuni" return "karshuni"
                case "ara" return "arabic"
                case "syc" return "syriac"
                default return ()
                
        (: although the transliteration may have another language than
        the transcription, the latter remains decisive for the prefix :)
        case "transliteration" return
            switch ($text/root()//tei:text[@type = "transcription"]/@xml:lang)
                case "ara" return "arabic"
                case "karshuni" return "karshuni"
                case "syc" return "syriac"
                default return ()
        default return ()
};

declare function coll:create-metadata-title-for-file-name($text as element(tei:text))
as xs:string {
    let $base-uri := coll:get-base-uri($text)
    let $metadata := doc($base-uri => replace("/data/", "/meta/"))
    return
        $metadata//tgmd:title
        => replace("[^a-zA-Z0-9]", "_")
        => replace("[_]+", "_")
};

declare function coll:get-base-uri($text as element(tei:text))
as xs:string{
    base-uri($text)
};

declare function coll:make-file-name-suffix($text as element(tei:text),
    $milestone-type as xs:string)
as xs:string {
    let $base-uri := coll:get-base-uri($text)
    let $file-name := coll:get-file-name($base-uri)
    let $type := $text/@type
    return
        $file-name || "-" || $type || "-" || $milestone-type || ".txt"
};

declare function coll:get-file-name($base-uri as xs:string)
as xs:string {
    tokenize($base-uri, "/")[last()]
    => substring-before(".xml")
};

declare function coll:get-relevant-text($text as element(tei:text))
as xs:string {
    let $milestones := coll:get-milestones-in-text($text)
    let $chunks := coll:get-chunks($milestones)
    let $texts := coll:get-relevant-text-from-chunks($chunks)
    return
        string-join($texts, " ")
};

declare function coll:get-milestones-in-text($text as element(tei:text))
as element(tei:milestone)+ {
    $text//tei:milestone
};

declare function coll:get-chunks($milestones as element(tei:milestone)+)
as element(tei:TEI)+ {
    for $milestone in $milestones return
        coll:get-chunk($milestone)
};

declare function coll:get-chunk($milestone as element(tei:milestone))
as element(tei:TEI) {
    let $root := $milestone/root()
    let $end-of-chunk := coll:get-end-of-chunk($milestone)
    return
        fragment:get-fragment-from-doc(
            $root,
            $milestone,
            $end-of-chunk,
            false(),
            true(),
            (""))
};

declare function coll:get-end-of-chunk($milestone as element(tei:milestone))
as node() {
    if (coll:has-following-milestone($milestone)) then
        coll:get-next-milestone($milestone)
    else
        $milestone/ancestor::tei:text[1]/tei:body/child::*[last()]
};

declare function coll:has-following-milestone($milestone as element(tei:milestone))
as xs:boolean {
    exists($milestone/following::tei:milestone[ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]])
};

declare function coll:get-next-milestone($milestone as element(tei:milestone))
as element(tei:milestone)? {
    $milestone/following::tei:milestone[ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]][1]
};

declare function coll:get-relevant-text-from-chunks($chunks as element(tei:TEI)+)
as xs:string {
    let $texts :=
        for $chunk in $chunks return
            coll:make-plain-text-from-chunk($chunk)
    return
        string-join($texts, " ")
        => normalize-space()
};

declare function coll:make-plain-text-from-chunk($chunk as element(tei:TEI))
as xs:string {
    let $texts := coll:get-relevant-text-nodes($chunk)
    let $prepared-texts :=
        for $text in $texts return
            coll:prepare-plain-text-creation($text)
    return
        coll:format-and-normalize-string($prepared-texts)
};

(:~ 
 : The following nodes shouldn't be considered for the plain text creation:
 : * sic (wrong text)
 : * surplus (surplus text)
 : * supplied (supplied by modern editors)
 : * colophons
 : * glyphs
 : * unclear (text unclear)
 : * catchwords (they simply serve to bind the books correctly and reduplicate text)
 : * note (they have been added later by another scribe)
 :)
declare function coll:get-relevant-text-nodes($chunk as element(tei:TEI))
as text()+ {
    (($chunk//text()
        [not(parent::tei:sic)]
        [not(parent::tei:surplus)])
        [not(parent::tei:supplied)])
        [not(parent::tei:*[@type = "colophon"])]
        [not(parent::tei:g)]
        [not(parent::tei:unclear)]
        [not(parent::tei:catchwords)]
        [not(parent::tei:note)]
};

declare function coll:prepare-plain-text-creation($text as text())
as xs:string {
    if ($text/preceding-sibling::*[1][self::tei:lb[@break = "no"]]) then
        "@" || $text
    else
        $text
};

declare function coll:format-and-normalize-string($strings as xs:string+)
as xs:string {
    string-join($strings, " ")
    => replace(" @", "")
    => replace("[\p{P}\n+]", "")
    => replace("\s+", " ")
};
