xquery version "3.1";

module namespace thtmlt="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "../modules/tapi-html.xqm";


declare
    %test:assertXPath("$result//@id = 'N4'")
function thtmlt:add-IDs()
as node()+ {
    let $manifest := doc($commons:data || "ahiqar_sample.xml")/*
    return
        tapi-html:add-IDs($manifest)
};


declare
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "82a") %test:assertXPath("$result[local-name(.) = 'pb']")
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "82a") %test:assertXPath("$result/@facs = 'textgrid:3r1p0'")
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "82a") %test:assertXPath("$result/@n = '82b'")
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "83b") %test:assertXPath("$result[local-name(.) = 'ab']")
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "83b") %test:assertXPath("matches($result, 'ܘܗܦܟܬ ܛܥܢܬ ܐܰܒܵܪܐ ܘܠܐ ܐܝܼܩܰܪ ܥܠ')")
function thtmlt:get-end-node($tei-xml-base-uri as xs:string,
    $page as xs:string)
as item()+ {
    let $node := doc($tei-xml-base-uri)/*
    let $start-node := $node//tei:pb[@n = $page and @facs]
    return
        tapi-html:get-end-node($start-node)
};


declare
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "82a") %test:assertXPath("$result//*[local-name(.) = 'add'][@place = 'margin'] = 'حقًا'")
function thtmlt:get-page-fragment($tei-xml-base-uri as xs:string,
    $page as xs:string)
as element() {
    tapi-html:get-page-fragment($tei-xml-base-uri, $page)
};
    
                        
declare
    %test:args("/db/apps/sade/textgrid/data/ahiqar_sample.xml", "82a") %test:assertXPath("$result//text()[matches(., 'حقًا')]")
function thtmlt:transform-fragment($tei-xml-base-uri as xs:string,
    $page as xs:string)
as element(xhtml:div) {
    let $fragment := tapi-html:get-page-fragment($tei-xml-base-uri, $page)
    return
        tapi-html:get-html-from-fragment($fragment)
};


declare
    %test:args("ahiqar_sample", "82a") %test:assertXPath("$result//text()[matches(., 'حقًا')]")
    %test:args("ahiqar_sample", "82a")
    (: checks if there is text at all in the result :)
    %test:assertXPath("$result//text()[matches(., '[\w]')]")
    (: if a div[@class = 'tei_body'] is present, the transformation has been successfull :)
    %test:assertXPath("$result[@class = 'tei_body']")
    (: this is some text on 82a (and thus should be part of the result) :)
    %test:assertXPath("$result//* = 'ܘܬܥܐܠܝ ܕܟܪܗ ܐܠܝ ܐܠܐܒܕ. ܘܢܟܬܒ ܟܒܪ'") 
    (: this is some text on 83a which shouldn't be part of the result :)
    %test:assertXPath("not($result//* = 'ܡܢ ܐܠܣܡܐ ܩܐܝܠܐ. ܒܚܝܬ ܐܬܟܠܬ ܐܘܠܐ ܥܠܝ ܐܠܐܨܢܐܡ' )")
function thtmlt:get-html($tei-xml-uri as xs:string,
    $page as xs:string)
as element(div) {
    tapi-html:get-html($tei-xml-uri, $page)
};
