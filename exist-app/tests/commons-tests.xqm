xquery version "3.1";

module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare variable $ct:restxq := "http://0.0.0.0:8080/exist/restxq/";
declare variable $ct:base-uri := "/db/data/textgrid/data/sample_teixml.xml";

declare
    %test:args("sample_edition") %test:assertEquals("sample_teixml")
function ct:get-xml-uri($manifest-uri as xs:string)
as xs:string {
    commons:get-xml-uri($manifest-uri)
};

declare
    %test:args("sample_edition") %test:assertXPath("$result//*[local-name(.) = 'title'] = 'The Proverbs or History of Aḥīḳar the wise, the scribe of Sanḥērībh,
               king of Assyria and Nineveh'")
function ct:get-tei-xml-for-manifest($manifest-uri) {
    commons:get-tei-xml-for-manifest($manifest-uri)
};


declare
    %test:args("sample_teixml", "data") %test:assertXPath("$result/*[local-name(.) = 'TEI']")
    %test:args("sample_teixml", "meta") %test:assertXPath("$result//* = 'Beispieldatei zum Testen'")
    %test:args("sample_edition", "agg") %test:assertXPath("$result//@* = 'textgrid:sample_teixml'")
    %test:args("sample_teixml", "sata") %test:assertError("COMMONS001")
    %test:args("qwerty", "data") %test:assertError("COMMONS002")
function ct:get-document($uri as xs:string,
    $type as xs:string)
as document-node()? {
    commons:get-document($uri, $type)
};

declare
    %test:args("sample_edition") %test:assertXPath("count($result) = 2 and $result = 'sample_teixml' and $result = 'ahiqar_tile'")
    %test:args("qwerty") %test:assertError("COMMONS002")
function ct:get-available-aggregates($uri as xs:string)
as xs:string+ {
    commons:get-available-aggregates($uri)
};

declare
    %test:assertXPath("$result//@id = 'N4'")
function ct:add-IDs()
as node()+ {
    let $manifest := doc($commons:data || "sample_teixml.xml")/*
    return
        commons:add-IDs($manifest)
};


declare
    %test:args("82a") %test:assertXPath("$result[local-name(.) = 'pb']")
    %test:args("82a") %test:assertXPath("$result/@facs = 'textgrid:3r1p0'")
    %test:args("82a") %test:assertXPath("$result/@n = '82b'")
    %test:args("84a") %test:assertXPath("$result[local-name(.) = 'ab']")
    %test:args("84a") %test:assertXPath("matches($result, 'ܢܕܢ')")
function ct:get-end-node($page as xs:string)
as item()+ {
    let $node := doc($ct:base-uri)/*
    let $start-node := $node//tei:pb[@n = $page and @facs]
    return
        commons:get-end-node($start-node)
};


declare
    %test:args("82a", "transcription") %test:assertXPath("$result//*[local-name(.) = 'add'][@place = 'margin'] = 'حقًا'")
function ct:get-page-fragment($page as xs:string,
    $text-type as xs:string)
as element() {
    commons:get-page-fragment($ct:base-uri, $page, $text-type)
};

declare
    %test:args("sample_teixml") %test:assertXPath("$result//*[local-name(.) = 'title'] = 'Beispieldatei zum Testen'")
function ct:get-metadata-file($uri as xs:string)
as document-node() {
    commons:get-metadata-file($uri)
};

declare
    %test:assertXPath("$result = 'Add_2020'")
    %test:assertXPath("$result = 'Sachau_290_Sachau_339'")
    %test:assertXPath("$result = 'Mingana_ar_christ_93_84'")
function ct:make-id-from-idno()
as xs:string+ {
    let $TEIs := (local:get-sample-tei(), local:get-tei-header-1(), local:get-tei-header-2())
    for $TEI in $TEIs return
        commons:make-id-from-idno($TEI)
};

declare
    %test:args("sample_teixml") %test:assertXPath("count($result) = 6")
    %test:args("sample_teixml") %test:assertXPath("$result = '82a'")
function ct:get-pages-in-TEI($uri as xs:string)
as xs:string+ {
    commons:get-pages-in-TEI($uri)
};

declare function local:get-sample-tei()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>Title</title>
                </titleStmt>
                <publicationStmt>
                    <p>Publication Information</p>
                </publicationStmt>
                <sourceDesc>
                    <msDesc>
                        <msIdentifier>
                            <institution>University of Cambridge - Cambridge University Library</institution>
                            <idno>Add. 2020</idno>
                        </msIdentifier>
                    </msDesc>
                </sourceDesc>
            </fileDesc>
        </teiHeader>
       <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <ab>Daß alle <sic>unsere</sic> Erkenntnis mit der <surplus>einen</surplus> Erfahrung anfange<supplied>,</supplied> daran </ab>
                                
                        <milestone unit="sayings"/>
                        <ab>Wenn <unclear>aber</unclear> gleich alle unsere Erkenntnis mit der Erfahrung anhebt<g>,</g> so entspringt sie<note>die Erkenntnis</note> darum <w type="colophon">doch nicht eben</w></ab>
                        
                        
                        <milestone unit="second_narrative_section"/>
                        <ab><catchwords>Es ist also wenigstens eine der näheren Untersuchung noch benötigte und nicht auf den</catchwords></ab> 
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function local:get-tei-header-1()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <sourceDesc>
                    <msDesc>
                        <msIdentifier>
                            <institution>University of Cambridge - Cambridge University Library</institution>
                            <idno>Sachau 290 (=Sachau 339)</idno>
                        </msIdentifier>
                    </msDesc>
                </sourceDesc>
            </fileDesc>
        </teiHeader>
    </TEI>
};

declare function local:get-tei-header-2()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <sourceDesc>
                    <msDesc>
                        <msIdentifier>
                            <institution>University of Cambridge - Cambridge University Library</institution>
                            <idno>Mingana ar. christ. 93[84]</idno>
                        </msIdentifier>
                    </msDesc>
                </sourceDesc>
            </fileDesc>
        </teiHeader>
    </TEI>
};
