xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tei2json/tests";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json" at "../modules/tei2json.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $t:sample-file := local:open-file("sample_teixml");
declare variable $t:sample-transliteration := $t:sample-file//tei:text[@type = "transliteration"];
declare variable $t:sample-transcription := $t:sample-file//tei:text[@type = "transcription"];

declare
    %test:assertEquals("works")
    %test:pending
function t:main() {
    tei2json:main()
};

declare
    %test:assertTrue
function t:create-json-collection-if-not-available() {
    let $create-collection := tei2json:create-json-collection-if-not-available()
    return
        xmldb:collection-available("/db/data/textgrid/json")
};

declare
    %test:assertXPath("count($result) gt 1")
    %test:assertXPath("$result/local-name() = 'TEI'")
function t:get-teis() {
    tei2json:get-teis()
};

declare
    %test:assertTrue
function t:has-text-milestone() {
    let $text := $t:sample-transliteration
    return
        tei2json:has-text-milestone($text)
};

declare
    %test:assertXPath("count($result) gt 0")
function t:get-transcriptions-and-transliterations()
as element(tei:text)+ {
    let $tokenized-tei := local:get-tokenized-tei-sample()
    return
        tei2json:get-transcriptions-and-transliterations($tokenized-tei)
};

declare function local:open-file($uri as xs:string)
as document-node() {
    doc($tei2json:data || "/" || $uri || ".xml")
};

declare
    %test:assertExists
    %test:assertXPath("$result//*[local-name(.) = 'ab']")
function t:get-chunk-successs()
as element(tei:TEI) {
    let $milestone-type := "first_narrative_section"
    return
        tei2json:get-chunk($t:sample-transliteration, $milestone-type)
};

declare
    %test:assertExists
    %test:assertXPath("not($result//*)")
function t:get-chunk-fail()
as element(tei:TEI) {
    let $milestone-type := "third_narrative_section"
    return
        tei2json:get-chunk($t:sample-transliteration, $milestone-type)
};

declare
    %test:assertXPath("$result[self::*[local-name(.) = 'milestone']]")
function t:get-end-of-chunk-milestone() {
    let $milestone := $t:sample-transliteration//tei:milestone[1]
    return
        tei2json:get-end-of-chunk($milestone)
};

declare
    %test:assertXPath("$result[self::*[local-name(.) = 'ab']]")
function t:get-end-of-chunk-end-of-text() {
    let $milestone := $t:sample-transliteration//tei:milestone[2]
    return
        tei2json:get-end-of-chunk($milestone)
};


declare
    %test:assertXPath("$result[self::*/string() = 'the end text']")
function t:get-end-of-chunk-end-of-text-2() {
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
        tei2json:get-end-of-chunk($milestone)
};

declare
    %test:assertTrue
function t:has-following-milestone-true()
as xs:boolean {
    let $milestone := $t:sample-transliteration//tei:milestone[1]
    return
        tei2json:has-following-milestone($milestone)
};

declare
    %test:assertFalse
function t:has-following-milestone-false()
as xs:boolean {
    let $milestone := $t:sample-transliteration//tei:milestone[2]
    return
        tei2json:has-following-milestone($milestone)
};

declare
    %test:assertXPath("map:get($result, 'id') = 'Borg ar 201'")
function t:make-map-per-witness() {
    let $tokens := local:get-tokenized-tei-sample()//tei:w
    return
        tei2json:make-map-per-witness($tokens)
};

declare function local:get-tokenized-tei-sample()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader/>
        <text>
            <group>
                <text xml:lang="eng" type="translation">
                    <body>
                        <ab/>
                    </body>
                </text>
                <text xml:lang="ara" type="transcription">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <ab>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_1" type="token">Daß</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_2" type="token">alle</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_3" type="token">unsere</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_4" type="token">Erkenntnis</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_5" type="token">mit</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_6" type="token">der</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_7" type="token">Erfahrung</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_8" type="token">anfange,</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.4.1_9" type="token">daran</w>
                        </ab>
                        <milestone unit="sayings"/>
                        <ab>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_1" type="token">Wenn</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_2" type="token">aber</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_3" type="token">gleich</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_4" type="token">alle</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_5" type="token">unsere</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_6" type="token">Erkenntnis</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_7" type="token">mit</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_8" type="token">der</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_9" type="token">Erfahrung</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_10" type="token">anhebt,</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_11" type="token">so</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_12" type="token">entspringt</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_13" type="token">sie</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_14" type="token">darum</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_15" type="token">doch</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_16" type="token">nicht</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.8.1_17" type="token">eben</w>
                        </ab>
                        <milestone unit="second_narrative_section"/>
                        <ab>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_1" type="token">Es</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_2" type="token">ist</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_3" type="token">also</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_4" type="token">wenigstens</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_5" type="token">eine</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_6" type="token">der</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_7" type="token">näheren</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_8" type="token">Untersuchung</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_9" type="token">noch</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_10" type="token">benötigte</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_11" type="token">und</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_12" type="token">nicht</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_13" type="token">auf</w>
                            <w xml:id="Borg_ar_201_N1.4.2.4.4.12.1_14" type="token">den</w>
                        </ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};
