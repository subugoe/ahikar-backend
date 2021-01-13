xquery version "3.1";

(:~
 : This module extracts the chunks marked as important for the collation from
 : the TEI files and uses them as an input for the plain text creation. These
 : serve as a basis for the collation with CollateX in the project's CI/CD
 : pipelines.
 :)

module namespace tapi-txt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace norm="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization" at "tapi-txt-normalization.xqm";

declare variable $tapi-txt:textgrid := "/db/apps/sade/textgrid";
declare variable $tapi-txt:data := $tapi-txt:textgrid || "/data";
declare variable $tapi-txt:txt := $tapi-txt:textgrid || "/txt";
declare variable $tapi-txt:milestone-types :=
    ("first_narrative_section",
    "sayings",
    "second_narrative_section",
    "parables",
    "third_narrative_section");


declare function tapi-txt:main() 
as xs:string+ {
    tapi-txt:create-txt-collection-if-not-available(),
    for $text in tapi-txt:get-transcriptions-and-transliterations() return
        for $milestone-type in $tapi-txt:milestone-types return
            let $relevant-text := tapi-txt:get-relevant-text($text, $milestone-type)
            return
                xmldb:store($tapi-txt:txt, tapi-txt:make-file-name($text, $milestone-type), $relevant-text, "text/plain")
};

declare function tapi-txt:get-milestone-types-per-text($text as element(tei:text))
as xs:string+ {
    $text//tei:milestone/@unit[./string() = $tapi-txt:milestone-types]/string()
};

declare function tapi-txt:create-txt-collection-if-not-available()
as xs:string? {
    if (xmldb:collection-available($tapi-txt:txt)) then
        ()
    else
        xmldb:create-collection($tapi-txt:textgrid, "txt")
};

declare function tapi-txt:get-transcriptions-and-transliterations()
as element(tei:text)+ {
    collection($tapi-txt:data)//tei:text[@type = ("transcription", "transliteration")][tapi-txt:has-text-milestone(.)]
};

declare function tapi-txt:has-text-milestone($text as element(tei:text))
as xs:boolean {
    exists($text//tei:milestone[@unit = $tapi-txt:milestone-types])
};

(:~
 : An example for the file name is 
 : syriac-Brit_Lib_Add_7200-3r131-transcription.txt
 :)
declare function tapi-txt:make-file-name($text as element(tei:text),
    $milestone-type as xs:string)
as xs:string {
    let $lang-prefix := tapi-txt:get-language-prefix($text)
    let $title-from-metadata := tapi-txt:create-metadata-title-for-file-name($text)
    let $uri-text-type-milestone := tapi-txt:make-file-name-suffix($text, $milestone-type)
    return
        $lang-prefix || "-" || $title-from-metadata || "-" || $uri-text-type-milestone
};

declare function tapi-txt:get-language-prefix($text as element(tei:text))
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

declare function tapi-txt:create-metadata-title-for-file-name($text as element(tei:text))
as xs:string {
    let $base-uri := tapi-txt:get-base-uri($text)
    let $metadata := doc($base-uri => replace("/data/", "/meta/"))
    return
        $metadata//tgmd:title
        => replace("[^a-zA-Z0-9]", "_")
        => replace("[_]+", "_")
};

declare function tapi-txt:get-base-uri($text as element(tei:text))
as xs:string{
    base-uri($text)
};

declare function tapi-txt:make-file-name-suffix($text as element(tei:text),
    $milestone-type as xs:string)
as xs:string {
    let $base-uri := tapi-txt:get-base-uri($text)
    let $file-name := tapi-txt:get-file-name($base-uri)
    let $type := $text/@type
    return
        $file-name || "-" || $type || "-" || $milestone-type || ".txt"
};

declare function tapi-txt:get-file-name($base-uri as xs:string)
as xs:string {
    tokenize($base-uri, "/")[last()]
    => substring-before(".xml")
};

declare function tapi-txt:get-relevant-text($text as element(tei:text),
    $milestone-type as xs:string)
as xs:string {
    let $chunk := tapi-txt:get-chunk($text, $milestone-type)
    (: this filler is needed where tapi-txt:get-relevant-text-from-chunks is
    empty because a manuscript doesn't have any text in the section of $milestone-type.
    nevertheless, we want this manuscript to be part of the collation in order
    to quickly see that said text is missing. however, compress:zip does not
    allow for empty files, so we insert at least a white space in the file. :)
    let $filler := " "
    return
        $filler || tapi-txt:get-relevant-text-from-chunks($chunk)
};

(:~
 : this function returns an empty tei:TEI element if the narrative section
 : searched for via $milestone-type does not exist in a manuscript. 
 :)
declare function tapi-txt:get-chunk($text as element(tei:text),
    $milestone-type as xs:string)
as element(tei:TEI) {
    let $root := $text/root()
    let $milestone := $text//tei:milestone[@unit = $milestone-type]
    return
        if (exists($milestone)) then
            let $end-of-chunk := tapi-txt:get-end-of-chunk($milestone)
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

declare function tapi-txt:get-end-of-chunk($milestone as element(tei:milestone))
as element() {
    if (tapi-txt:has-following-milestone($milestone)) then 
        tapi-txt:get-next-milestone($milestone)
    else
        $milestone/ancestor::tei:text[1]/tei:body/child::*[last()]
};

declare function tapi-txt:has-following-milestone($milestone as element(tei:milestone))
as xs:boolean {
    exists($milestone/following::*[local-name(.) = 'milestone'][./ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]])
};

declare function tapi-txt:get-next-milestone($milestone as element(tei:milestone))
as element(tei:milestone)? {
    $milestone/following::*[local-name(.) = 'milestone'][./ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]][1]
};

declare function tapi-txt:get-relevant-text-from-chunks($chunks as element(tei:TEI)+)
as xs:string {
    let $texts :=
        for $chunk in $chunks return
            tapi-txt:make-plain-text-from-chunk($chunk)
    return
        string-join($texts, " ")
        => normalize-space()
};

declare function tapi-txt:make-plain-text-from-chunk($chunk as element(tei:TEI))
as xs:string {
    let $texts := tapi-txt:get-relevant-text-nodes($chunk)
    let $prepared-texts :=
        for $text in $texts return
            tapi-txt:prepare-plain-text-creation($text)
    return
        tapi-txt:format-and-normalize-string($prepared-texts)
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
declare function tapi-txt:get-relevant-text-nodes($chunk as element(tei:TEI))
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

declare function tapi-txt:prepare-plain-text-creation($text as text())
as xs:string {
    if ($text/preceding-sibling::*[1][self::tei:lb[@break = "no"]]) then
        "@" || $text
    else
        $text
};

declare function tapi-txt:format-and-normalize-string($strings as xs:string+)
as xs:string {
    string-join($strings, " ")
    => replace(" @", "")
    => replace("[\p{P}\n+]", "")
    => replace("\s+", " ")
    => norm:get-txt-without-diacritics()
};


(:~
 : Returns the tei:text of a document as indicated by the @type parameter.
 : 
 : Due to the structure of the Ahikar project we can pass either an edition or
 : an XML file to the API endpoint for plain text creation.
 : This function determines the correct file which serves as a basis for the plain text.
 : 
 : @param $document The URI of a resource
 : @param $type Indicates the @type of tei:text to be processed
 : @return The tei:text element to be serialized as plain text
 :)
declare function tapi-txt:get-TEI-text($document-uri as xs:string,
    $type as xs:string)
as element(tei:text) {
    if (tapi-txt:is-document-tei-xml($document-uri)) then
        commons:get-document($document-uri, "data")//tei:text[@type = $type]
    else
        tapi-txt:get-tei-xml-uri-from-edition
        => tapi-txt:get-text-of-type($type)
};


declare function tapi-txt:is-document-tei-xml($document-uri as xs:string) {
    let $format := tapi-txt:get-format($document-uri)
    return
        if ($format = "text/xml") then
            true()
        else
            false()
};


(:~
 : Returns the TextGrid metadata type of a resource.
 : 
 : @param $uri The URI of the resource
 : @return The resource's format as tgmd:format
 :)
declare function tapi-txt:get-format($uri as xs:string) as xs:string {
    doc($commons:meta || $uri || ".xml")//tgmd:format
};


declare function tapi-txt:get-tei-xml-uri-from-edition($document-uri as xs:string)
as xs:string {
    commons:get-available-aggregates($document-uri)
    => tapi-txt:get-tei-xml-from-aggregates()
};


declare function tapi-txt:get-tei-xml-from-aggregates($aggregates as xs:string+)
as xs:string {
    for $agg in $aggregates return
        if (tapi-txt:get-format($agg) = "text/xml") then
            $agg
        else
            ()
};


declare function tapi-txt:get-text-of-type($uri as xs:string,
    $type as xs:string)
as element(tei:text) {
    commons:get-document($uri, "data")//tei:text[@type = $type]
};


declare function tapi-txt:compress-to-zip()
as xs:base64Binary* {
    compression:zip(xs:anyURI($commons:tg-collection || "/txt/"), false())
};
