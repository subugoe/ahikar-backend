xquery version "3.1";

module namespace ttt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tapi-txt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt" at "../modules/tapi-txt.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $ttt:sample-file := local:open-file("ahiqar_sample");
declare variable $ttt:sample-transliteration := $ttt:sample-file//tei:text[@type = "transliteration"];
declare variable $ttt:sample-transcription := $ttt:sample-file//tei:text[@type = "transcription"];

declare
    %test:args("ahiqar_sample") %test:assertExists
    %test:args("1234") %test:assertError("org.exist.xquery.XPathException")
function ttt:open-file($uri as xs:string) as document-node() {
    local:open-file($uri)
};

declare
    %test:assertExists
function ttt:get-next-milestone-succecss()
as element(tei:milestone)? {
    let $milestone := $ttt:sample-transliteration//tei:milestone[1]
    return
        tapi-txt:get-next-milestone($milestone)
};

declare
    %test:assertEmpty
function ttt:get-next-milestone-fail()
as element(tei:milestone)? {
    let $milestone := $ttt:sample-transliteration//tei:milestone[2]
    return
        tapi-txt:get-next-milestone($milestone)
};

declare
    %test:assertExists
    %test:assertXPath("$result//*[local-name(.) = 'ab']")
function ttt:get-chunk()
as element(tei:TEI) {
    let $milestone-type := "first_narrative_section"
    return
        tapi-txt:get-chunk($ttt:sample-transliteration, $milestone-type)
};


declare
     %test:assertEquals("some text that should be used display some text without a space")
function ttt:make-plain-text-from-chunk()
as xs:string {
    let $chunk := 
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <group>
                    <text xml:lang="ara">
                        <body xml:lang="ara">
                            <ab>some <persName>text</persName>          that should 
                            
                            
                            
                            be used</ab>
                            <ab>
                                <choice>
                                    <sic>no display</sic>
                                    <corr>display</corr>
                                </choice>
                                <surplus>no display</surplus>
                                <supplied>no display</supplied>
                                <ab type="colophon">no display</ab>
                                <g>[</g>
                                <unclear>no display</unclear>
                                <catchwords>no displayno display</catchwords>
                                <note>no display</note>
                            </ab>
                            <ab>some text with</ab>
                            <ab><lb break="no"/>out a space</ab>
                        </body>
                    </text>
                </group>
            </text>
        </TEI>
    return
        tapi-txt:make-plain-text-from-chunk($chunk)
};


declare
    %test:assertEquals("some text with")
function ttt:prepare-plain-text-creation-no-lb()
as xs:string {
    let $chunk :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <group>
                    <text xml:lang="ara">
                        <body xml:lang="ara">
                            <ab>some text with</ab>
                        </body>
                    </text>
                </group>
            </text>
        </TEI>
    let $text := $chunk//tei:ab/text()
    return
        tapi-txt:prepare-plain-text-creation($text)
};

declare
    %test:assertEquals("@out a space.")
function ttt:prepare-plain-text-creation-lb()
as xs:string {
    let $chunk :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <group>
                    <text xml:lang="ara">
                        <body xml:lang="ara">
                            <ab><lb break="no"/>out a space.</ab>
                        </body>
                    </text>
                </group>
            </text>
        </TEI>
    let $text := $chunk//tei:ab/text()
    return
        tapi-txt:prepare-plain-text-creation($text)
};

declare
    %test:assertXPath("count($result) = 6")
function ttt:get-relevant-text-nodes()
as text()+ {
    let $chunk := 
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <group>
                    <text xml:lang="ara">
                        <body xml:lang="ara">
                            <ab>some <persName>text</persName>          that should 
                            
                            
                            
                            be used</ab>
                            <ab>
                                <choice>
                                    <sic>no display</sic>
                                    <corr>display</corr>
                                </choice>
                                <surplus>no display</surplus>
                                <supplied>no display</supplied>
                                <ab type="colophon">no display</ab>
                                <g>[</g>
                                <unclear>no display</unclear>
                                <catchwords>no displayno display</catchwords>
                                <note>no display</note>
                            </ab>
                            <ab>some text with</ab>
                            <ab><lb break="no"/>out a space</ab>
                        </body>
                    </text>
                </group>
            </text>
        </TEI>
    return
        tapi-txt:get-relevant-text-nodes($chunk)
};

declare
    %test:args(" @test") %test:assertEquals("test")
    %test:args("interpunction.") %test:assertEquals("interpunction")
    %test:args("white               spaces") %test:assertEquals("white spaces")
    %test:args("some
    
    new lines") %test:assertEquals("some new lines")
function ttt:format-and-normalize-string($string as xs:string)
as xs:string {
    tapi-txt:format-and-normalize-string($string)
};

declare
    %test:assertTrue
function ttt:create-txt-collection-if-not-available() {
    let $create-collection := tapi-txt:create-txt-collection-if-not-available()
    return
        if (xmldb:collection-available("/db/apps/sade/textgrid/txt/")) then
            true()
        else
            false()
};

declare
    %test:assertXPath("count($result) gt 0")
function ttt:get-transcriptions-and-transliterations()
as element(tei:text)+ {
    tapi-txt:get-transcriptions-and-transliterations()
};

declare
    %test:args("ara") %test:assertEquals("arabic")
    %test:args("karshuni") %test:assertEquals("karshuni")
    %test:args("syc") %test:assertEquals("syriac")
function ttt:get-language-prefix-transcriptions($lang as xs:string)
as xs:string {
    let $text := 
        <text xmlns="http://www.tei-c.org/ns/1.0" type="transcription"
        xml:lang="{$lang}" />
    return
        tapi-txt:get-language-prefix($text)
};

declare
    %test:args("ara", "ara") %test:assertEquals("arabic")
    %test:args("ara", "karshuni") %test:assertEquals("karshuni")
    %test:args("ara", "syc") %test:assertEquals("syriac")
    %test:args("karshuni", "ara") %test:assertEquals("arabic")
    %test:args("karshuni", "karshuni") %test:assertEquals("karshuni")
    %test:args("karshuni", "syc") %test:assertEquals("syriac")
    %test:args("syriac", "ara") %test:assertEquals("arabic")
    %test:args("syriac", "karshuni") %test:assertEquals("karshuni")
    %test:args("syriac", "syc") %test:assertEquals("syriac")
function ttt:get-language-prefix-transliteration($lang-transliteration as xs:string,
$lang-transcription as xs:string)
as xs:string {
    let $TEI :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text type="transliteration" xml:lang="{$lang-transliteration}" />
            <text type="transcription" xml:lang="{$lang-transcription}" />
        </TEI>
    let $text := $TEI/tei:text[1]
    return
        tapi-txt:get-language-prefix($text)
};

declare
    %test:assertEquals("/db/apps/sade/textgrid/data/ahiqar_sample.xml")
function ttt:get-base-uri()
as xs:string {
    tapi-txt:get-base-uri($ttt:sample-transcription)
};

declare
    %test:assertEquals("Beispieldatei_zum_Testen")
function ttt:create-metadata-title-for-file-name()
as xs:string {
    tapi-txt:create-metadata-title-for-file-name($ttt:sample-transcription)
};

declare
    %test:assertEquals("karshuni-Beispieldatei_zum_Testen-ahiqar_sample-transcription-first_narrative_section.txt")
function ttt:make-file-name()
as xs:string {
    tapi-txt:make-file-name($ttt:sample-transcription, "first_narrative_section")
};

declare
    %test:assertEquals("ahiqar_sample-transcription-first_narrative_section.txt")
function ttt:make-file-name-suffix()
as xs:string {
    tapi-txt:make-file-name-suffix($ttt:sample-transcription, "first_narrative_section")
};

declare
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml") %test:assertEquals("ahiqar_sample")
function ttt:get-file-name($base-uri as xs:string)
as xs:string {
    tapi-txt:get-file-name($base-uri)
};

declare
    %test:args("first_narrative_section") %test:assertEquals("text of the first narrative section")
    %test:args("sayings") %test:assertEquals("some sayings")
function ttt:get-relevant-text($milestone-type as xs:string) {
    let $TEI :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <body>
                    <ab>some ignored text</ab>
                    <milestone unit="first_narrative_section"/>
                    <ab>text of the first narrative section</ab>
                    <milestone unit="sayings"/>
                    <ab>some sayings</ab>
                </body>
            </text>
        </TEI>
    return
        tapi-txt:get-relevant-text($TEI/tei:text, $milestone-type)
};

declare
    %test:assertXPath("$result[self::*[local-name(.) = 'milestone']]")
function ttt:get-end-of-chunk-milestone() {
    let $milestone := $ttt:sample-transliteration//tei:milestone[1]
    return
        tapi-txt:get-end-of-chunk($milestone)
};

declare
    %test:assertXPath("$result[self::*[local-name(.) = 'ab']]")
function ttt:get-end-of-chunk-end-of-text() {
    let $milestone := $ttt:sample-transliteration//tei:milestone[2]
    return
        tapi-txt:get-end-of-chunk($milestone)
};


declare
    %test:assertXPath("$result[self::*/string() = 'the end text']")
function ttt:get-end-of-chunk-end-of-text-2() {
    let $TEI :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <group>
                    <text type="transliteration">
                        <body>
                            <ab>some text<tei:milestone unit="sayings"/> more text</ab>
                            <ab>the end text</ab>
                        </body>
                    </text>
                    <text type="transcription">
                        <body>
                            <ab>some text2<tei:milestone unit="sayings"/> more text</ab>
                            <ab>another end text</ab>
                        </body>
                    </text>
                </group>
            </text>
        </TEI>
    let $milestone := $TEI//tei:text[@type = "transliteration"]//tei:milestone
    
    return
        tapi-txt:get-end-of-chunk($milestone)
};

declare
    %test:assertTrue
function ttt:has-following-milestone-true()
as xs:boolean {
    let $milestone := $ttt:sample-transliteration//tei:milestone[1]
    return
        tapi-txt:has-following-milestone($milestone)
};

declare
    %test:assertFalse
function ttt:has-following-milestone-false()
as xs:boolean {
    let $milestone := $ttt:sample-transliteration//tei:milestone[2]
    return
        tapi-txt:has-following-milestone($milestone)
};

declare
    %test:assertEquals("chunk1 relevant text more relevant text chunk2 relevant text more relevant text")
function ttt:get-relevant-text-from-chunks()
as xs:string {
    let $chunk1 :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <body>
                    <ab>chunk1: relevant text</ab>
                    <ab>more relevant text <unclear>irrelevant</unclear>.</ab>
                </body>
            </text>
        </TEI>
    let $chunk2 :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <body>
                    <ab>chunk2: relevant text</ab>
                    <ab>more relevant text <surplus>irrelevant</surplus></ab>
                </body>
            </text>
        </TEI>
    return
        tapi-txt:get-relevant-text-from-chunks(($chunk1, $chunk2))
};

declare
    %test:assertTrue
function ttt:has-text-milestone-succcess() {
    let $text:= 
        <text xmlns="http://www.tei-c.org/ns/1.0">
            <body>
                <ab>some text <milestone unit="parables"/></ab>
            </body>
        </text>
    return
        tapi-txt:has-text-milestone($text)
};

declare
    %test:assertFalse
function ttt:has-text-milestones-fail() {
    let $text:= 
        <text xmlns="http://www.tei-c.org/ns/1.0">
            <body>
                <ab>some text</ab>
            </body>
        </text>
    return
        tapi-txt:has-text-milestone($text)  
};

declare function local:open-file($uri as xs:string)
as document-node() {
    doc($tapi-txt:data || "/" || $uri || ".xml")
};


declare
    %test:assertXPath("$result = 'first_narrative_section'")
    %test:assertXPath("$result = 'second_narrative_section'")
function ttt:get-milestone-types-per-text()
as xs:string+ {
    tapi-txt:get-milestone-types-per-text($ttt:sample-transliteration)
};

declare
    %test:args("ahiqar_sample", "transcription")
    %test:assertXPath("$result[local-name(.) = 'text' and @type = 'transcription']")
function ttt:get-tei($document-uri as xs:string,
    $type as xs:string)
as element() {
    tapi-txt:get-TEI-text($document-uri, $type)
};

declare
    %test:args("ahiqar_sample") %test:assertEquals("text/xml")
    %test:args("ahiqar_agg") %test:assertEquals("text/tg.edition+tg.aggregation+xml")
function ttt:tgmd-format($uri as xs:string)
as xs:string {
    tapi-txt:get-format($uri)
};


declare
    %test:args("ahiqar_sample", "transcription")
    %test:assertXPath("$result[local-name(.) = 'text' and @type = 'transcription']")
function ttt:get-tei($document as xs:string, $type as xs:string) as element() {
    tapi-txt:get-TEI-text($document, $type)
};


declare
    %test:args("ahiqar_agg") %test:assertEquals("ahiqar_sample")
function ttt:get-tei-xml-uri-from-edition($document as xs:string) {
    tapi-txt:get-tei-xml-uri-from-edition($document)
};


declare
    %test:args("ahiqar_agg") %test:assertEquals("ahiqar_sample")
function ttt:get-edition-aggregates-without-uri-namespace($document as xs:string) {
    tapi-txt:get-edition-aggregates-without-uri-namespace($document)
};


declare
    %test:args("ahiqar_sample") %test:assertEquals("ahiqar_sample")
function ttt:get-tei-xml-from-aggregates($aggregates as xs:string+) {
    tapi-txt:get-tei-xml-from-aggregates($aggregates)
};


declare 
    %test:args("ahiqar_sample", "transliteration") %test:assertXPath("$result[@type = 'transliteration']")
function ttt:get-text-of-type($uri as xs:string, $type as xs:string) {
    tapi-txt:get-text-of-type($uri, $type)
};

declare
    %test:args("ahiqar_sample") %test:assertTrue
    %test:args("ahiqar_agg") %test:assertFalse
function ttt:is-document-tei-xml($document-uri as xs:string)
as xs:boolean {
    tapi-txt:is-document-tei-xml($document-uri)
};

declare
    %test:assertExists
function ttt:compress-text()
as xs:base64Binary {
    tapi-txt:compress-to-zip()
};
