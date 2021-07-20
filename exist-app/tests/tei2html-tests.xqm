xquery version "3.1";

(: 
 : This module contains the unit tests for tei2html.xqm. 
 :)

module namespace t2ht="http://ahikar.sub.uni-goettingen.de/ns/tei2html-tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tei2html="http://ahikar.sub.uni-goettingen.de/ns/tei2html" at "../modules/tei2html.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare
    %test:assertTrue
function t2ht:test-sample-data() {
    let $sample-data := local:get-sample-file()
    let $transformed-sample-data := tei2html:transform($sample-data)
        => serialize()
        => replace("[\n\t\r]", "")
        => replace("[\s]+", "")
    let $reference-data := local:get-reference-file()
        => serialize()
        => replace("[\n\t\r]", "")
        => replace("[\s]+", "")
    return
        deep-equal($transformed-sample-data, $reference-data)
};


declare
    %test:assertExists
    %test:assertEquals("some text")
function t2ht:text()
as text() {
    let $element := <ab xmlns="http://www.tei-c.org/ns/1.0">some text</ab>
    return
        tei2html:transform($element)/text()
};
    

declare
    %test:assertEmpty
function t2ht:comment()
as empty-sequence() {
    let $element := comment{"some text"}
    return
        tei2html:transform($element)
};

declare
    %test:assertEmpty
function t2ht:pi-standalone()
as empty-sequence() {
    let $element := processing-instruction doc-processor2 {'version="4.3"'}
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("not($result//processing-instruction())")
function t2ht:pi-context()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">ܒܢܝܿܬܼ ܠܝ ܥܠܬܼܐ ܚܕܐ ܪܒܬܼܐ܂
            <?oxy_comment_start author="simon" timestamp="20200829T182848+0200" comment="loyal_obligation_gods"?>
            ܘܣܿܡܬܼ
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:args ("ab") %test:assertTrue
    %test:args ("body") %test:assertTrue
    %test:args ("cb") %test:assertTrue
    %test:args ("l") %test:assertTrue
    %test:args ("lg") %test:assertTrue
    %test:args ("add") %test:assertFalse
    %test:args ("persName") %test:assertFalse
function t2ht:is-block-element-true($element-name)
as xs:boolean {
    let $element :=
        element {QName("http://www.tei-c.org/ns/1.0", $element-name)} {
            "a line"
        }
    return
        tei2html:is-block-element($element)
};

declare
    %test:assertExists
    %test:assertEquals("add colophon margin")
function t2ht:make-class-attribute()
as xs:string {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <add type="colophon" place="margin">
                a line
            </add>
        </ab>
    return
        tei2html:make-class-attribute-values($element/tei:add)
};

declare
    %test:assertFalse
function t2ht:make-class-attributes-reds()
as xs:boolean {
    let $element1 :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <hi rend="color(red)">
                a line
            </hi>
        </ab>
    let $element2 :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <hi rend="#red">
                a line
            </hi>
        </ab>
    let $element3 :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <hi rendition="#red">
                a line
            </hi>
        </ab>
    let $values := for $e in ($element1, $element2, $element3) return
        tei2html:make-class-attribute-values($e/tei:hi)
    return
        $values != "hi red"
};

declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("$result/text() = 'a line'")
function t2ht:ab()
as element() {
    let $element := <ab xmlns="http://www.tei-c.org/ns/1.0">a line</ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("contains($result/@class, 'header')")
function t2ht:ab-header-like()
as element() {
    let $element := <ab xmlns="http://www.tei-c.org/ns/1.0" type="header">a line</ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("contains($result/@class, 'margin-top')")
function t2ht:ab-margin-top()
as element() {
    let $element := <ab xmlns="http://www.tei-c.org/ns/1.0" rend="margin-top">a line</ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result//*[local-name(.) = 'span']")
    %test:assertXPath("contains($result//*/@class, 'abbr')")
function t2ht:abbr()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <abbr>pqm</abbr>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("contains($result//*/@class, 'add')")
    %test:assertXPath("contains($result//*/@class, 'top')")
function t2ht:add()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <add place="top">pqm</add>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'catchwords'")
function t2ht:catchwords-1()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <catchwords>pqm</catchwords>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'div']")
    %test:assertXPath("$result//*/@class = 'cb 1'")
function t2ht:catchwords-2()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <cb n="1">pqm</cb>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'damage half-page'")
function t2ht:damage()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <damage extent="half-page">pqm</damage>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'del strikedthrough'")
function t2ht:del()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <del rend="strikedthrough">pqm</del>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'g'")
function t2ht:g()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <g>pqm</g>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'gap lost'")
function t2ht:gap()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <gap reason="lost">pqm</gap>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'h1']")
    %test:assertXPath("$result//*/@class = 'head'")
function t2ht:head()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <head>pqm</head>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'hi underline'")
function t2ht:hi-underline()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <hi rend="underline">pqm</hi>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'hi red'")
function t2ht:hi-red()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <hi rend="color(red)">pqm</hi>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'hi italic'")
function t2ht:hi-italic()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <hi rend="italic">pqm</hi>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("$result/@class = 'l'")
function t2ht:l()
as element() {
    let $element := <l xmlns="http://www.tei-c.org/ns/1.0">pqm</l>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'label'")
function t2ht:label()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <label >pqm</label>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'div'][@class = 'body']")
    %test:assertXPath("$result/*[local-name(.) = 'div'][@class = 'ab']")
    %test:assertXPath("$result/*[local-name(.) = 'div'][@class = 'ab']/*[local-name(.) = 'a'][@class = 'no-break' and @id = 'lb_1' and @href = '#lb_2']")
    %test:assertXPath("$result/*[local-name(.) = 'div'][@class = 'ab']/*[local-name(.) = 'a'][@class = 'no-break' and @id = 'lb_2' and @href = '#lb_1']")
function t2ht:lb()
as element() {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("$result/@class = 'lg'")
function t2ht:lg()
as element() {
    let $element := <lg xmlns="http://www.tei-c.org/ns/1.0"><l>pqm</l></lg>
    return
        tei2html:transform($element)
};


declare
    %test:assertEmpty
function t2ht:milestone()
as empty-sequence() {
    let $element := <milestone xmlns="http://www.tei-c.org/ns/1.0" unit="first_narrative_section"/>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result/*/@class = 'note'")
function t2ht:note()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <note>some text</note>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'orig'")
function t2ht:orig()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <orig >some text</orig>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertEmpty
function t2ht:pb()
as empty-sequence() {
    let $element := <pb xmlns="http://www.tei-c.org/ns/1.0" n="82a"/>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'quote'")
function t2ht:quote()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <quote>some text</quote>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'seg ara'")
function t2ht:seg-language()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <seg xml:lang="ara">نبح<?oxy_comment_end?><?oxy_comment_end mid="110"?>)</seg>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'seg colophon'")
function t2ht:seg-colophon()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <seg type="colophon">ܗܵܪܟܿܐ ܫܸܠܡܲܬܸ</seg>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'a'][@id = '1234' and @href = '#9876']")
    %test:assertXPath("$result/*[local-name(.) = 'a'][@id = '9876' and @href = '#1234']")
function t2ht:seg-linking()
as element() {
    let $element := 
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <seg id="1234" xml:id="seg_1" next="#seg_2">
                <hi rend="color(red)">
                    <g>]</g>
                </hi>
                some text that
            </seg>
            <seg id="9876" xml:id="seg_2" prev="#seg_1">
                belongs to another text
                <hi rend="color(red)">
                    <g>[</g>
                </hi>
            </seg>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'sic'")
function t2ht:sic()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <sic>some text</sic>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'supplied'")
function t2ht:supplied()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <supplied>some text</supplied>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'persName'")
function t2ht:persName()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <persName>some text</persName>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'placeName'")
function t2ht:placeName()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <placeName>some text</placeName>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'surplus'")
function t2ht:surplus()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <surplus>some text</surplus>
        </ab>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result/*[local-name(.) = 'span']")
    %test:assertXPath("$result//*/@class = 'unclear illegible'")
function t2ht:unclear()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <unclear reason="illegible">some text</unclear>
        </ab>
    return
        tei2html:transform($element)
};


declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("$result/@class = 'vacant-page'")
function t2ht:vacant-page()
as element() {
    let $element := <body xmlns="http://www.tei-c.org/ns/1.0"/>
    return
        tei2html:transform($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("$result/@class = 'vacant-page'")
function t2ht:make-vacant-page()
as element() {
    tei2html:make-vacant-page()
};

declare
    %test:assertXPath("$result[local-name(.) = 'span']")
    %test:assertXPath("$result/@class = 'unclear illegible'")
function t2ht:make-default-return-inline()
as element() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            <unclear reason="illegible">some text</unclear>
        </ab>
    return
        tei2html:make-default-return($element/tei:unclear)
};

declare
    %test:assertXPath("$result[local-name(.) = 'div']")
    %test:assertXPath("$result/@class = 'l'")
function t2ht:make-default-return-block()
as element() {
    let $element := <l xmlns="http://www.tei-c.org/ns/1.0">some text</l>
    return
        tei2html:make-default-return($element)
};

declare
    %test:assertFalse
function t2ht:has-page-content-false()
as xs:boolean {
    let $element := <body xmlns="http://www.tei-c.org/ns/1.0"/>
    return
        tei2html:has-page-content($element)
};

declare
    %test:assertTrue
function t2ht:has-page-content-true()
as xs:boolean {
     let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>some test</ab>
        </body>
    return
        tei2html:has-page-content($element)
};

declare
    %test:assertTrue
function t2ht:is-linking-another-element-true-next()
as xs:boolean {
    let $element :=
        <persName xmlns="http://www.tei-c.org/ns/1.0" next="#id">
            some text
        </persName>
    return
        tei2html:references-another-element($element)
};

declare
    %test:assertTrue
function t2ht:is-linking-another-element-true-prev()
as xs:boolean {
    let $element :=
        <persName xmlns="http://www.tei-c.org/ns/1.0" prev="#id">
            some text
        </persName>
    return
        tei2html:references-another-element($element)
};

declare
    %test:assertTrue
function t2ht:is-linking-another-element-true-target()
as xs:boolean {
    let $element :=
        <ref xmlns="http://www.tei-c.org/ns/1.0" target="#id #id_2">
            some text
        </ref>
    return
        tei2html:references-another-element($element)
};

declare
    %test:assertFalse
function t2ht:is-linking-another-element-false()
as xs:boolean {
    let $element :=
        <seg xmlns="http://www.tei-c.org/ns/1.0">
            some text
        </seg>
    return
        tei2html:references-another-element($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'a'][@class = 'seg'][@href = '#N4.4.2.6.4.24.1'][@id = 'N4.4.2.6.4.26.2']")
function t2ht:make-xhtml-a-with-prev()
as element() {
    let $element := local:get-sample-file()//tei:seg[@prev]
    return
        tei2html:make-xhtml-a($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'a' and @class = 'seg' and @id ='N4.4.2.6.4.26.2' and @href = '#N4.4.2.6.4.24.1']")
function t2ht:make-xhtml-a-with-prev-and-id()
as element() {
    let $element := local:get-sample-file()//tei:seg[@prev]
    return
        tei2html:make-xhtml-a($element)
};

declare
    %test:assertXPath("$result[local-name(.) = 'a' and @class = 'ref' and @href = '#N4.4.2.6.4.24.1']")
function t2ht:ref()
as element() {
    let $element := local:get-sample-file()//tei:ref
    return tei2html:transform($element)
};

declare
    %test:assertEquals("#N4.4.2.6.4.26.2")
function t2ht:get-href-value-next()
as xs:string {
    let $element := local:get-sample-file()//tei:seg[@next]
    return tei2html:get-href-value($element)
};

declare
    %test:assertEquals("#N4.4.2.6.4.24.1")
function t2ht:get-href-value-prev()
as xs:string {
    let $element := local:get-sample-file()//tei:seg[@prev]
    return tei2html:get-href-value($element)
};

declare
    %test:assertEquals("#N4.4.2.6.4.24.1")
function t2ht:get-href-value-target()
as xs:string {
    let $element := local:get-sample-file()//tei:ref
    return
        tei2html:get-href-value($element)
};


declare
    %test:assertEquals("N4.4.2.6.4.24.1")
function t2ht:find-referenced-id()
as xs:string {
    let $doc := local:get-sample-file()
    let $ref := $doc//tei:ref
    let $xmlid := tei2html:get-referenced-xmlid($ref)
    return
        tei2html:find-referenced-node-id($ref, $xmlid)
};

declare
    %test:assertEquals("seg_1")
function t2ht:get-referenced-xmlid-to-id-target()
as xs:string {
    let $ref := local:get-sample-file()//tei:ref
    return
        tei2html:get-referenced-xmlid($ref)
};


declare
    %test:assertEquals("seg_1")
function t2ht:get-referenced-xmlid-to-id-prev()
as xs:string {
    let $ref := local:get-sample-file()//tei:seg[@prev]
    return
        tei2html:get-referenced-xmlid($ref)
};

declare
    %test:assertEquals("seg_2")
function t2ht:get-referenced-xmlid-to-id-next()
as xs:string {
    let $ref := local:get-sample-file()//tei:seg[@next]
    return
        tei2html:get-referenced-xmlid($ref)
};


declare function local:get-sample-file()
as element() {
    <body xmlns="http://www.tei-c.org/ns/1.0" xml:lang="syc">
        <head id="N4.4.2.6.4.8">
            <hi id="N4.4.2.6.4.8.2" rend="color(red)">܀ܪܹܫܵܐ ܩܕܡܝܵܐ ܕܬܫܥܝܼܬܼܵܐ
                    <persName id="N4.4.2.6.4.8.2.3">ܕܐܲܚܝܼܩܲܪ܀</persName>
            </hi>
        </head>
        <ab id="N4.4.2.6.4.22">ܟܕ ܡܝܼܬܼ <persName id="N4.4.2.6.4.22.2">ܣܢܚܪܝܼܒܼ</persName> ܡܠܟܐ <placeName id="N4.4.2.6.4.22.4">ܕܐܵܬܼܘܪ</placeName>
        </ab>
        <ab id="N4.4.2.6.4.24">
            <seg id="N4.4.2.6.4.24.1" xml:id="seg_1" next="#seg_2">
                <hi id="N4.4.2.6.4.24.1.4" rend="color(red)">
                    <g id="N4.4.2.6.4.24.1.4.2">]</g>
                </hi>
                    ܒܫܢܬܼ ܫܹܬܡܵܐܐ ܘܬܲܫܥ ܘܫܒܥܝܼܢ
                </seg>
        </ab>
        <ab id="N4.4.2.6.4.26">
            <span id="N1.5.2-1" type="motif" n="loyal_obligation_gods" next="#N1.5.2-2">
                <seg id="N4.4.2.6.4.26.2" xml:id="seg_2" prev="#seg_1">ܩܕܼܡ
                    <persName id="N4.4.2.6.4.26.2.4">ܡܫܝܼܚܵܐ܂</persName>
                    <hi id="N4.4.2.6.4.26.2.6" rend="color(red)">
                        <g id="N4.4.2.6.4.26.2.6.2">[</g>
                    </hi>
                </seg>
                <add id="N4.4.2.6.4.26.4" place="margin">
                    <ref id="N4.4.2.6.4.26.4.3" target="#seg_1 #seg2">ܠܝܬܿ ܒܐܨܚܬܵܐ ܚܕܐܵ ܣܝܩܘܡܵܐ</ref>
                </add>܂ ܛܒܼ ܣܓܝܼ<add id="N4.4.2.6.4.26.6" place="inline">ܐܹܢܵܐ</add>
            </span>
        </ab>
        <ab id="N4.4.2.6.4.44">
            <span id="N1.5.2-2" type="motif" n="loyal_obligation_gods">ܐܹܢܵܐ
                <persName id="N4.4.2.6.4.44.2">ܐܚܝܼܩܪ</persName>
            </span>
                ܐܸܙܹܿܠܬܼ ܘܩܲܪܒܹܬܼ ܕܒܼܚܹ̈ܐ <catchwords id="N4.4.2.6.4.44.5">ܠܐܠܗܐ</catchwords>
        </ab>
    </body>
};

declare function local:get-reference-file()
as element() {
    <xhtml:div xmlns:xhtml="http://www.w3.org/1999/xhtml" id="" dir="rtl" class="body syc">
        <xhtml:h1 id="N4.4.2.6.4.8" class="head">
            <xhtml:span id="N4.4.2.6.4.8.2" class="hi red">܀ܪܹܫܵܐ ܩܕܡܝܵܐ ܕܬܫܥܝܼܬܼܵܐ
                        <xhtml:span id="N4.4.2.6.4.8.2.3" class="persName">ܕܐܲܚܝܼܩܲܪ܀</xhtml:span>
            </xhtml:span>
        </xhtml:h1>
        <xhtml:div id="N4.4.2.6.4.22" class="ab">ܟܕ ܡܝܼܬܼ <xhtml:span id="N4.4.2.6.4.22.2" class="persName">ܣܢܚܪܝܼܒܼ</xhtml:span> ܡܠܟܐ <xhtml:span id="N4.4.2.6.4.22.4" class="placeName">ܕܐܵܬܼܘܪ</xhtml:span>
        </xhtml:div>
        <xhtml:div id="N4.4.2.6.4.24" class="ab">
            <xhtml:a id="N4.4.2.6.4.24.1" class="seg" href="#N4.4.2.6.4.26.2">
                <xhtml:span id="N4.4.2.6.4.24.1.4" class="hi red">
                    <xhtml:span id="N4.4.2.6.4.24.1.4.2" class="g">]</xhtml:span>
                </xhtml:span>
                        ܒܫܢܬܼ ܫܹܬܡܵܐܐ ܘܬܲܫܥ ܘܫܒܥܝܼܢ
                    </xhtml:a>
        </xhtml:div>
        <xhtml:div id="N4.4.2.6.4.26" class="ab">
            <xhtml:span id="N1.5.2-1" type="loyal_obligation_gods" class="motif" data-next="#N1.5.2-2">
                <xhtml:a id="N4.4.2.6.4.26.2" class="seg" href="#N4.4.2.6.4.24.1">ܩܕܼܡ
                        <xhtml:span id="N4.4.2.6.4.26.2.4" class="persName">ܡܫܝܼܚܵܐ܂</xhtml:span>
                    <xhtml:span id="N4.4.2.6.4.26.2.6" class="hi red">
                        <xhtml:span id="N4.4.2.6.4.26.2.6.2" class="g">[</xhtml:span>
                    </xhtml:span>
                </xhtml:a>
                <xhtml:span id="N4.4.2.6.4.26.4" class="add margin">
                    <xhtml:a id="N4.4.2.6.4.26.4.3" class="ref" href="#N4.4.2.6.4.24.1">ܠܝܬܿ ܒܐܨܚܬܵܐ ܚܕܐܵ ܣܝܩܘܡܵܐ</xhtml:a>
                </xhtml:span>܂ ܛܒܼ ܣܓܝܼ<xhtml:span id="N4.4.2.6.4.26.6" class="add inline">ܐܹܢܵܐ</xhtml:span>
            </xhtml:span>
        </xhtml:div>
        <xhtml:div id="N4.4.2.6.4.44" class="ab">
            <xhtml:span id="N1.5.2-2" type="loyal_obligation_gods" class="motif">ܐܹܢܵܐ
                    <xhtml:span id="N4.4.2.6.4.44.2" class="persName">ܐܚܝܼܩܪ</xhtml:span>
            </xhtml:span>
                    ܐܸܙܹܿܠܬܼ ܘܩܲܪܒܹܬܼ ܕܒܼܚܹ̈ܐ <xhtml:span id="N4.4.2.6.4.44.5" class="catchwords">ܠܐܠܗܐ</xhtml:span>
        </xhtml:div>
    </xhtml:div>
};
