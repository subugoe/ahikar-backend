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

declare variable $tapi-txt:textgrid := "/db/apps/sade/textgrid";
declare variable $tapi-txt:data := $tapi-txt:textgrid || "/data";
declare variable $tapi-txt:txt := $tapi-txt:textgrid || "/txt";


declare function tapi-txt:main() 
as xs:string+ {
    tapi-txt:create-txt-collection-if-not-available(),
    for $text in tapi-txt:get-transcriptions-and-transliterations() return
        let $relevant-text := tapi-txt:get-relevant-text($text)
        let $file-name := tapi-txt:make-file-name($text)
        return
            xmldb:store($tapi-txt:txt, $file-name, $relevant-text, "text/plain")
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
    collection($tapi-txt:data)//tei:text[@type = ("transcription", "transliteration")]
        [tapi-txt:has-text-milestone(.)]
};

declare function tapi-txt:has-text-milestone($text as element(tei:text))
as xs:boolean {
    if ($text//tei:milestone) then
        true()
    else
        false()
};

(:~
 : An example for the file name is 
 : syriac-Brit_Lib_Add_7200-3r131-transcription.txt
 :)
declare function tapi-txt:make-file-name($text as element(tei:text))
as xs:string {
    let $lang-prefix := tapi-txt:get-language-prefix($text)
    let $title-from-metadata := tapi-txt:create-metadata-title-for-file-name($text)
    let $uri-plus-text-type := tapi-txt:make-file-name-suffix($text)
    return
        $lang-prefix || "-" || $title-from-metadata || "-" || $uri-plus-text-type
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

declare function tapi-txt:make-file-name-suffix($text as element(tei:text))
as xs:string {
    let $base-uri := tapi-txt:get-base-uri($text)
    let $file-name := tapi-txt:get-file-name($base-uri)
    let $type := $text/@type
    return
        $file-name || "-" || $type || ".txt"
};

declare function tapi-txt:get-file-name($base-uri as xs:string)
as xs:string {
    tokenize($base-uri, "/")[last()]
    => substring-before(".xml")
};

declare function tapi-txt:get-relevant-text($text as element(tei:text))
as xs:string {
    let $milestones := tapi-txt:get-milestones-in-text($text)
    let $chunks := tapi-txt:get-chunks($milestones)
    let $texts := tapi-txt:get-relevant-text-from-chunks($chunks)
    return
        string-join($texts, " ")
};

declare function tapi-txt:get-milestones-in-text($text as element(tei:text))
as element(tei:milestone)+ {
    $text//tei:milestone
};

declare function tapi-txt:get-chunks($milestones as element(tei:milestone)+)
as element(tei:TEI)+ {
    for $milestone in $milestones return
        tapi-txt:get-chunk($milestone)
};

declare function tapi-txt:get-chunk($milestone as element(tei:milestone))
as element(tei:TEI) {
    let $root := $milestone/root()
    let $end-of-chunk := tapi-txt:get-end-of-chunk($milestone)
    return
        fragment:get-fragment-from-doc(
            $root,
            $milestone,
            $end-of-chunk,
            false(),
            true(),
            (""))
};

declare function tapi-txt:get-end-of-chunk($milestone as element(tei:milestone))
as node() {
    if (tapi-txt:has-following-milestone($milestone)) then
        tapi-txt:get-next-milestone($milestone)
    else
        $milestone/ancestor::tei:text[1]/tei:body/child::*[last()]
};

declare function tapi-txt:has-following-milestone($milestone as element(tei:milestone))
as xs:boolean {
    if ($milestone/following::tei:milestone[ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]]) then
        true()
    else
        false()
};

declare function tapi-txt:get-next-milestone($milestone as element(tei:milestone))
as element(tei:milestone)? {
    $milestone/following::tei:milestone[ancestor::tei:text[1] = $milestone/ancestor::tei:text[1]][1]
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