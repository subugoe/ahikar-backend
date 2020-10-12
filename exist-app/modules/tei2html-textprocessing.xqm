xquery version "3.1";

(:~
 : This module deals with the text processing during the transformation of TEI
 : to XHTML. Its main purpose is to detect cases of word breaks at line ends;
 : These are be indicated with xhtml:a[@class = "no-break"] elements pointing
 : to each other via @id and @href.
 : 
 : Example (TEI):
 :  <ab>some text which has a bro</ab>
 :  <ab><lb break="no"/>ken word in it</ab>
 : 
 : Example (result):
 :  <div class="ab">some text which has a <a class="no-break" id="N.1.1" href="N.1.2">bro</a></div>
 :  <div class="ab"><a class="no-break" id="N.1.2" href="N1.1">ken</a> word in it.</div>
 : 
 : @see https://intranet.sub.uni-goettingen.de/display/prjAhiqar/Text+Styling+Specification
 :)

module namespace tei2html-text="http://ahikar.sub.uni-goettingen.de/ns/tei2html/textprocessing";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace functx="http://www.functx.com";


declare function tei2html-text:process-text($text as text())
as node()* {
    if(normalize-space($text) = "") then
        ()
    else if (tei2html-text:has-broken-word-at-line-end($text)) then
        tei2html-text:make-lb-combi-at-line-end($text)
        
    else if(tei2html-text:has-broken-word-at-line-beginning($text)) then
        tei2html-text:make-lb-combi-at-line-beginning($text)
        
    else
        $text
};


declare function tei2html-text:has-broken-word-at-line-end($text as text())
as xs:boolean {
    tei2html-text:is-text-node-last-in-line($text)
    and tei2html-text:is-word-at-line-end-part-of-break($text)
};


declare function tei2html-text:is-text-node-last-in-line($text as text())
as xs:boolean {
    let $line := tei2html-text:get-ancestor-line($text)
    let $last-text := $line//text()[last()]
    return
        $text = $last-text
};


declare function tei2html-text:get-ancestor-line($text as text())
as element() {
    if ($text/ancestor::*[self::tei:ab or self::tei:l or self::tei:head]) then
        $text/ancestor::*[self::tei:ab or self::tei:l or self::tei:head][1]
    
    (: in some cases we have margin notes or the like that don't belong to a
     : certain line. these are encoded in tei:add outside of tei:ab. :)    
    else if ($text/ancestor::*[self::tei:add]) then
        $text/ancestor::*[self::tei:add]
        
    else
        ()
};


declare function tei2html-text:is-word-at-line-end-part-of-break($text as text())
as xs:boolean {
    let $line := tei2html-text:get-ancestor-line($text)
    let $next-line := $line/following-sibling::*[1]
    return
        exists($next-line/child::*[1][self::tei:lb[@break = "no"]])
};


declare function tei2html-text:has-broken-word-at-line-beginning($text as text())
as xs:boolean {
    tei2html-text:is-text-node-first-in-line($text)
    and tei2html-text:is-word-at-line-beginning-part-of-break($text)
};


declare function tei2html-text:is-text-node-first-in-line($text as text())
as xs:boolean {
    let $line := tei2html-text:get-ancestor-line($text)
    let $first-text := $line//text()[1]
    return
        $text = $first-text
};


declare function tei2html-text:is-word-at-line-beginning-part-of-break($text as text())
as xs:boolean {
    exists($text/preceding-sibling::*[1][self::tei:lb[@break = "no"]])
};


declare function tei2html-text:make-lb-combi-at-line-end($text as text())
as node()+ {
    let $part-of-break := tei2html-text:get-broken-word-at-line-end($text)
    let $unaffected := tei2html-text:get-text-unaffected-by-word-break($text, $part-of-break)
    return
        (
            text{$unaffected},
            tei2html-text:make-xhtml-a-no-break($text, $part-of-break)
        )
};


declare function tei2html-text:get-broken-word-at-line-end($text as text())
as xs:string {
    tokenize($text, " ")[last()]
};


declare function tei2html-text:get-text-unaffected-by-word-break($text as text(),
    $part-of-word-break as xs:string)
as xs:string? {
    let $result := functx:get-matches-and-non-matches($text, $part-of-word-break)
    return
        if ($result[self::non-match]) then
            $result[self::non-match]
        else
            ()
};

declare function tei2html-text:make-xhtml-a-no-break($text as text(),
    $part-of-break as xs:string)
as element(xhtml:a) {
    element xhtml:a {
        attribute class {"no-break"},
        attribute id {tei2html-text:get-id-for-word-breaks($text)},
        attribute href {tei2html-text:get-href-id-for-word-breaks($text)},
        $part-of-break
    }
};


declare function tei2html-text:get-id-for-word-breaks($text as text())
as xs:string {
    let $id-integer := tei2html-text:get-id-integer($text)
    return
        "lb_" || $id-integer
};


declare function tei2html-text:get-id-integer($text as text())
as xs:integer {
    let $previous-lb := $text/preceding::tei:lb[1]
    return
        if (not($previous-lb)) then
            1
        else if ($previous-lb 
        and tei2html-text:is-lb-first-on-page($previous-lb)
        and $text/preceding-sibling::*[1][self::tei:lb]) then
            2
        else
            let $preceding-lbs := count($text/preceding::tei:lb)
            return
                (: word break at line beginning, right after tei:lb. these
                 : always have an even integer part because they are the second
                 : part of a pair.:)
                if ($text/preceding-sibling::*[1][self::tei:lb]) then
                    $preceding-lbs * 2
                (: word break at line end. these always have an odd integer part
                 : because they are the first part of a pair.:)                
                else
                    ($preceding-lbs * 2) + 1
};


declare function tei2html-text:is-lb-first-on-page($lb as element(tei:lb)?)
as xs:boolean {
    not(exists($lb/preceding::tei:lb))
};


declare function tei2html-text:get-href-id-for-word-breaks($text as text())
as xs:string {
    let $id-integer := tei2html-text:get-id-integer($text)
    return
        if (tei2html-text:is-word-at-line-beginning-part-of-break($text)) then
            "#lb_" || $id-integer - 1
        else if (tei2html-text:is-word-at-line-end-part-of-break($text)) then
            "#lb_" || $id-integer + 1
        else
            ""
};

declare function tei2html-text:make-lb-combi-at-line-beginning($text as text())
as node()+ {
    let $part-of-break := tei2html-text:get-broken-word-at-line-beginning($text)
    let $unaffected := tei2html-text:get-text-unaffected-by-word-break($text, $part-of-break)
    return
        (
            tei2html-text:make-xhtml-a-no-break($text, $part-of-break),
            text{$unaffected}
        )
};


declare function tei2html-text:get-broken-word-at-line-beginning($text as text())
as xs:string {
    tokenize($text, " ")[1]
};
