xquery version "3.1";

(: 
 : This module contains the unit tests for tei2xhtml-textprocessing.xqm. 
 :)

module namespace t2htextt="http://ahikar.sub.uni-goettingen.de/ns/tei2html-textprocessing-tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tei2html-text="http://ahikar.sub.uni-goettingen.de/ns/tei2html/textprocessing" at "../modules/tei2html-textprocessing.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare
    %test:assertTrue
function t2htextt:is-word-at-line-end-part-of-break-true()
as xs:boolean {
    let $body :=         
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    let $element := $body/tei:ab[1]/text()
    return
        tei2html-text:is-word-at-line-end-part-of-break($element)
};

declare
    %test:assertFalse
function t2htextt:is-word-at-line-end-part-of-break-false()
as xs:boolean {
    let $body :=         
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    let $element := $body/tei:ab[2]/text()
    return
        tei2html-text:is-word-at-line-end-part-of-break($element)
};


declare
    %test:assertTrue
function t2htextt:is-text-node-last-in-line-true()
as xs:boolean {
    let $element :=
        <l xmlns="http://www.tei-c.org/ns/1.0">
            some text
            <add>more text</add>
            and the rest of the line
        </l>
    let $text := $element/tei:add/following-sibling::text()
    return
        tei2html-text:is-text-node-last-in-line($text)
};


declare
    %test:assertFalse
function t2htextt:is-text-node-last-in-line-false()
as xs:boolean {
    let $element :=
        <l xmlns="http://www.tei-c.org/ns/1.0">
            some text
            <add>more text</add>
            and the rest of the line
        </l>
    let $text := $element/tei:add/text()
    return
        tei2html-text:is-text-node-last-in-line($text)
};

declare
    %test:assertEquals("sen")
function t2htextt:get-broken-word-at-line-end()
as xs:string {
    let $text := text{"this is my sen"}
    return
        tei2html-text:get-broken-word-at-line-end($text)
};

declare
    %test:assertEquals("tence.")
function t2htextt:get-broken-word-at-line-beginning()
as xs:string {
    let $text := text{"tence. It has been split."}
    return
        tei2html-text:get-broken-word-at-line-beginning($text)
};

declare
    %test:assertEquals("this is my ")
function t2htextt:get-text-unaffected-by-word-break-1()
as xs:string {
    let $text := text{"this is my sen"}
    let $part-of-word-break := tei2html-text:get-broken-word-at-line-end($text)
    return
        tei2html-text:get-text-unaffected-by-word-break($text, $part-of-word-break)
};


declare
    %test:assertEquals(" It has been split.")
function t2htextt:get-text-unaffected-by-word-break-2()
as xs:string {
    let $text := text{"tence. It has been split."}
    let $part-of-word-break := tei2html-text:get-broken-word-at-line-beginning($text)
    return
        tei2html-text:get-text-unaffected-by-word-break($text, $part-of-word-break)
};

declare
    %test:assertTrue
function t2htextt:is-text-node-first-line-true()
as xs:boolean {
    let $element :=
        <l xmlns="http://www.tei-c.org/ns/1.0">
            some text
            <add>more text</add>
            and the rest of the line
        </l>
    let $text := $element/text()[1]
    return
        tei2html-text:is-text-node-first-in-line($text)
};

declare
    %test:assertFalse
function t2htextt:is-text-node-first-line-false()
as xs:boolean {
    let $element :=
        <l xmlns="http://www.tei-c.org/ns/1.0">
            some text
            <add>more text</add>
            and the rest of the line
        </l>
    let $text := $element/tei:add/text()
    return
        tei2html-text:is-text-node-first-in-line($text)
};

declare
    %test:assertExists
    %test:assertXPath("$result[local-name(.) = 'ab']")
function t2htextt:get-ancestor-line-ab() {
    let $element :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
            some text
            <add>more text</add>
            and the rest of the line
        </ab>
    let $text := $element/tei:add/text()
    return
        tei2html-text:get-ancestor-line($text)
};

declare
    %test:assertExists
    %test:assertXPath("$result[local-name(.) = 'l']")
function t2htextt:get-ancestor-line-line() {
    let $element :=
        <l xmlns="http://www.tei-c.org/ns/1.0">
            some text
            <add>more text</add>
            and the rest of the line
        </l>
    let $text := $element/text()[1]
    return
        tei2html-text:get-ancestor-line($text)
};

declare
    %test:assertExists
    %test:assertXPath("$result[local-name(.) = 'add']")
function t2htextt:get-ancestor-line-add() {
    let $element :=
        <add xmlns="http://www.tei-c.org/ns/1.0">
            some text and the rest of the line
        </add>
    let $text := $element/text()[1]
    return
        tei2html-text:get-ancestor-line($text)
};

declare
    %test:assertExists
    %test:assertXPath("$result[local-name(.) = 'head']")
function t2htextt:get-ancestor-line-head() {
    let $element :=
        <head xmlns="http://www.tei-c.org/ns/1.0">
            some text and the rest of the line
        </head>
    let $text := $element/text()[1]
    return
        tei2html-text:get-ancestor-line($text)
};

declare
    %test:assertTrue
function t2htextt:is-word-at-line-beginning-part-of-break-true()
as xs:boolean {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:is-word-at-line-beginning-part-of-break($text)
};

declare
    %test:assertFalse
function t2htextt:is-word-at-line-beginning-part-of-break-false()
as xs:boolean {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:is-word-at-line-beginning-part-of-break($text)
};

declare
    %test:assertXPath("$result[local-name(.) = 'a'] = 'sen'")
function t2htextt:make-no-break-span()
as element() {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    return
        tei2html-text:make-xhtml-a-no-break($element/tei:ab[1]/text(), "sen")
};

declare
    %test:assertXPath("$result[1][self::text()] = 'this is my '")
    %test:assertXPath("$result[2][local-name(.) = 'a' and @class = 'no-break'] = 'sen'")
function t2htextt:make-lb-combi-at-line-end()
as node()+ {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:make-lb-combi-at-line-end($text)
};


declare
    %test:assertXPath("$result[1][local-name(.) = 'a' and @class = 'no-break'] = 'tence.'")
    %test:assertXPath("$result[2][self::text()] = ' Some more text.'")
function t2htextt:make-lb-combi-at-line-beginning()
as node()+ {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:make-lb-combi-at-line-beginning($text)
};

declare
    %test:assertEquals("lb_1")
function t2htextt:get-id-for-word-breaks-beginning-first()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:get-id-for-word-breaks($text)
};

declare
    %test:assertEquals("lb_2")
function t2htextt:get-id-for-word-breaks-end-first()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:get-id-for-word-breaks($text)
};

declare
    %test:assertEquals("lb_3")
function t2htextt:get-id-for-word-breaks-end-multiple()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[4]/text()
    return
        tei2html-text:get-id-for-word-breaks($text)
};

declare
    %test:assertEquals("lb_4")
function t2htextt:get-id-for-word-breaks-beginning-multiple()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[5]/text()
    return
        tei2html-text:get-id-for-word-breaks($text)
};

declare
    %test:assertTrue
function t2htextt:is-lb-first-on-page-true() {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $lb := $element/tei:ab[2]/tei:lb
    return
        tei2html-text:is-lb-first-on-page($lb)
};

declare
    %test:assertFalse
function t2htextt:is-lb-first-on-page-false() {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $lb := $element/tei:ab[5]/tei:lb
    return
        tei2html-text:is-lb-first-on-page($lb)
};

declare
    %test:assertEquals("#lb_4")
function t2htextt:get-href-id-for-word-breaks-line-end-1()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[4]/text()
    return
        tei2html-text:get-href-id-for-word-breaks($text)
};


declare
    %test:assertEquals("#lb_3")
function t2htextt:get-href-id-for-word-breaks-line-beginning-1()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[5]/text()
    return
        tei2html-text:get-href-id-for-word-breaks($text)
};

declare
    %test:assertEquals("#lb_2")
function t2htextt:get-href-id-for-word-breaks-line-end-2()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:get-href-id-for-word-breaks($text)
};


declare
    %test:assertEquals("#lb_1")
function t2htextt:get-href-id-for-word-breaks-line-beginning-2()
as xs:string {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:get-href-id-for-word-breaks($text)
};




declare
    %test:assertEquals(1)
function t2htextt:get-id-integer-1()
as xs:integer {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:get-id-integer($text)
};

declare
    %test:assertEquals(2)
function t2htextt:get-id-integer-2()
as xs:integer {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:get-id-integer($text)
};


declare
    %test:assertEquals(3)
function t2htextt:get-id-integer-3()
as xs:integer {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[4]/text()
    return
        tei2html-text:get-id-integer($text)
};

declare
    %test:assertEquals(4)
function t2htextt:get-id-integer-4()
as xs:integer {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[5]/text()
    return
        tei2html-text:get-id-integer($text)
};


declare
    %test:assertTrue
function t2htextt:has-lb-at-line-end-true()
as xs:boolean {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:has-broken-word-at-line-end($text)
};

declare
    %test:assertFalse
function t2htextt:has-lb-at-line-end-false()
as xs:boolean {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:has-broken-word-at-line-end($text)
};

declare
    %test:assertTrue
function t2htextt:has-lb-at-line-beginning-true()
as xs:boolean {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[2]/text()
    return
        tei2html-text:has-broken-word-at-line-beginning($text)
};

declare
    %test:assertFalse
function t2htextt:has-lb-at-line-beginning-false()
as xs:boolean {
    let $element :=
        <body xmlns="http://www.tei-c.org/ns/1.0">
            <ab>lorem ip</ab>
            <ab><lb break="no"/>sum. dolor sit amet.</ab>
            <ab>a line without breaks.</ab>
            <ab>this is my sen</ab>
            <ab><lb break="no"/>tence. Some more text.</ab>
        </body>
    let $text := $element/tei:ab[1]/text()
    return
        tei2html-text:has-broken-word-at-line-beginning($text)
};


declare
    %test:assertEmpty
function t2htextt:process-text() {
    let $text := text{" "}
    return
        tei2html-text:process-text($text)
};