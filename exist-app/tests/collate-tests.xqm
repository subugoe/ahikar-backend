xquery version "3.1";

module namespace coll-tests="http://ahikar.sub.uni-goettingen.de/ns/coll-tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace coll="http://ahikar.sub.uni-goettingen.de/ns/collate" at "../modules/collate.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $coll-tests:sample-file := local:open-file("ahiqar_sample");
declare variable $coll-tests:sample-transliteration := $coll-tests:sample-file//tei:text[@type = "transliteration"];
declare variable $coll-tests:sample-transcription := $coll-tests:sample-file//tei:text[@type = "transcription"];

declare
    %test:args("ahiqar_sample") %test:assertExists
    %test:args("1234") %test:assertError("org.exist.xquery.XPathException")
function coll-tests:open-file($uri as xs:string) as document-node() {
    local:open-file($uri)
};

declare
    %test:assertXPath("count($result) = 2")
function coll-tests:get-milestones-in-text()
as element(tei:milestone)* {
    coll:get-milestones-in-text($coll-tests:sample-transliteration)
};

declare
    %test:assertExists
function coll-tests:get-next-milestone-succecss()
as element(tei:milestone)? {
    let $milestone := $coll-tests:sample-transliteration//tei:milestone[1]
    return
        coll:get-next-milestone($milestone)
};

declare
    %test:assertEmpty
function coll-tests:get-next-milestone-fail()
as element(tei:milestone)? {
    let $milestone := $coll-tests:sample-transliteration//tei:milestone[2]
    return
        coll:get-next-milestone($milestone)
};

declare
    %test:assertExists
    %test:assertXPath("$result//*[local-name(.) = 'ab']")
function coll-tests:get-chunk()
as element(tei:TEI) {
    let $milestone := $coll-tests:sample-transliteration//tei:milestone[1]
    return
        coll:get-chunk($milestone)
};


declare
     %test:assertEquals("some text that should be used display some text without a space")
function coll-tests:make-plain-text-from-chunk()
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
        coll:make-plain-text-from-chunk($chunk)
};


declare
    %test:assertEquals("some text with")
function coll-tests:prepare-plain-text-creation-no-lb()
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
        coll:prepare-plain-text-creation($text)
};

declare
    %test:assertEquals("@out a space.")
function coll-tests:prepare-plain-text-creation-lb()
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
        coll:prepare-plain-text-creation($text)
};

declare
    %test:assertXPath("count($result) = 6")
function coll-tests:get-relevant-text-nodes()
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
        coll:get-relevant-text-nodes($chunk)
};

declare
    %test:args(" @test") %test:assertEquals("test")
    %test:args("interpunction.") %test:assertEquals("interpunction")
    %test:args("white               spaces") %test:assertEquals("white spaces")
    %test:args("some
    
    new lines") %test:assertEquals("some new lines")
function coll-tests:format-and-normalize-string($string as xs:string)
as xs:string {
    coll:format-and-normalize-string($string)
};

declare
    %test:assertTrue
function coll-tests:create-txt-collection-if-not-available() {
    let $create-collection := coll:create-txt-collection-if-not-available()
    return
        if (xmldb:collection-available("/db/apps/sade/textgrid/txt/")) then
            true()
        else
            false()
};

declare
    %test:assertXPath("count($result) gt 0")
function coll-tests:get-transcriptions-and-transliterations()
as element(tei:text)+ {
    coll:get-transcriptions-and-transliterations()
};

declare
    %test:args("ara") %test:assertEquals("arabic")
    %test:args("karshuni") %test:assertEquals("karshuni")
    %test:args("syc") %test:assertEquals("syriac")
function coll-tests:get-language-prefix-transcriptions($lang as xs:string)
as xs:string {
    let $text := 
        <text xmlns="http://www.tei-c.org/ns/1.0" type="transcription"
        xml:lang="{$lang}" />
    return
        coll:get-language-prefix($text)
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
function coll-tests:get-language-prefix-transliteration($lang-transliteration as xs:string,
$lang-transcription as xs:string)
as xs:string {
    let $TEI :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text type="transliteration" xml:lang="{$lang-transliteration}" />
            <text type="transcription" xml:lang="{$lang-transcription}" />
        </TEI>
    let $text := $TEI/tei:text[1]
    return
        coll:get-language-prefix($text)
};

declare
    %test:assertEquals("/db/apps/sade/textgrid/data/ahiqar_sample.xml")
function coll-tests:get-base-uri()
as xs:string {
    coll:get-base-uri($coll-tests:sample-transcription)
};

declare
    %test:assertEquals("Beispieldatei_zum_Testen")
function coll-tests:create-metadata-title-for-file-name()
as xs:string {
    coll:create-metadata-title-for-file-name($coll-tests:sample-transcription)
};

declare
    %test:assertEquals("karshuni-Beispieldatei_zum_Testen-ahiqar_sample-transcription.txt")
function coll-tests:make-file-name()
as xs:string {
    coll:make-file-name($coll-tests:sample-transcription)
};

declare
    %test:assertEquals("ahiqar_sample-transcription.txt")
function coll-tests:make-file-name-suffix()
as xs:string {
    coll:make-file-name-suffix($coll-tests:sample-transcription)
};

declare
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml") %test:assertEquals("ahiqar_sample")
function coll-tests:get-file-name($base-uri as xs:string)
as xs:string {
    coll:get-file-name($base-uri)
};

declare
    %test:assertEquals("text of the first narrative section some sayings")
function coll-tests:get-relevant-text() {
    let $TEI :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <body>
                    <ab>some ignored text</ab>
                    <milestone unit="first_narrative_section"/>
                    <ab>text of the first narrative section</ab>
                    <milestone unit="saying"/>
                    <ab>some sayings</ab>
                </body>
            </text>
        </TEI>
    return
        coll:get-relevant-text($TEI/tei:text)
};

declare
    %test:assertXPath("count($result) = 2")
function coll-tests:get-chunks() {
    let $milestones := coll:get-milestones-in-text($coll-tests:sample-transliteration)
    return
        coll:get-chunks($milestones)
};

declare
    %test:assertXPath("$result[self::*[local-name(.) = 'milestone']]")
function coll-tests:get-end-of-chunk-milestone() {
    let $milestone := coll:get-milestones-in-text($coll-tests:sample-transliteration)[1]
    return
        coll:get-end-of-chunk($milestone)
};

declare
    %test:assertXPath("$result[self::*[local-name(.) = 'ab']]")
function coll-tests:get-end-of-chunk-end-of-text() {
    let $milestone := coll:get-milestones-in-text($coll-tests:sample-transliteration)[2]
    return
        coll:get-end-of-chunk($milestone)
};


declare
    %test:assertXPath("$result[self::*/string() = 'the end text']")
function coll-tests:get-end-of-chunk-end-of-text-2() {
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
        coll:get-end-of-chunk($milestone)
};

declare
    %test:assertTrue
function coll-tests:has-following-milestone-true()
as xs:boolean {
    let $milestone := coll:get-milestones-in-text($coll-tests:sample-transliteration)[1]
    return
        coll:has-following-milestone($milestone)
};

declare
    %test:assertFalse
function coll-tests:has-following-milestone-false()
as xs:boolean {
    let $milestone := coll:get-milestones-in-text($coll-tests:sample-transliteration)[2]
    return
        coll:has-following-milestone($milestone)
};

declare
    %test:assertEquals("chunk1 relevant text more relevant text chunk2 relevant text more relevant text")
function coll-tests:get-relevant-text-from-chunks()
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
        coll:get-relevant-text-from-chunks(($chunk1, $chunk2))
};

declare
    %test:assertTrue
function coll-tests:has-text-milestone-succcess() {
    let $text:= 
        <text xmlns="http://www.tei-c.org/ns/1.0">
            <body>
                <ab>some text <milestone unit="parables"/></ab>
            </body>
        </text>
    return
        coll:has-text-milestone($text)
};

declare
    %test:assertFalse
function coll-tests:has-text-milestones-fail() {
    let $text:= 
        <text xmlns="http://www.tei-c.org/ns/1.0">
            <body>
                <ab>some text</ab>
            </body>
        </text>
    return
        coll:has-text-milestone($text)  
};

declare function local:open-file($uri as xs:string)
as document-node() {
    doc($coll:data || "/" || $uri || ".xml")
};
