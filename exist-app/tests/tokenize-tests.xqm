xquery version "3.1";

(: 
 : This module contains the unit tests for tei2html.xqm. 
 :)

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tokenize/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "../modules/tokenize.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:assertTrue
function t:main() {
    let $src-TEI := t:create-and-store-test-data()
    let $target-TEI := local:get-sample-result()
    return
        deep-equal(tokenize:main($src-TEI), $target-TEI)
};


declare
    %test:assertXPath("$result/local-name() = 'ab' and count($result//text()) = 2 ")
function t:add-ids-single-node()
as node()* {
    let $node := <ab xmlns="http://www.tei-c.org/ns/1.0">some text</ab>
    let $id-prefix := "t_Add_2020"
    return
        tokenize:add-ids($node, $id-prefix)
};

declare
    %test:assertTrue
function t:is-text-relevant-true()
as xs:boolean {
    let $node := <ab xmlns="http://www.tei-c.org/ns/1.0">some text</ab>
    return
        tokenize:is-text-relevant($node/text())
};

declare
    %test:assertFalse
function t:is-text-relevant-false()
as xs:boolean {
    let $node := <ab xmlns="http://www.tei-c.org/ns/1.0"><surplus>some text</surplus></ab>
    return
        tokenize:is-text-relevant($node/descendant::text())
};

declare
    %test:assertXPath("count($result) = 2 
        and $result/local-name() = 'w'
        and $result[1]/@xml:id = 't_Add_2020_N1.1_1'
        and $result[2]/@xml:id = 't_Add_2020_N1.1_2' ")
function t:add-id-to-text()
as element(tei:w)+ {
    let $node := <ab xmlns="http://www.tei-c.org/ns/1.0">some text </ab>
    let $id-prefix := "t_Add_2020"
    return
        tokenize:add-id-to-text($node/text(), $id-prefix)
};

declare function t:create-and-store-test-data()
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

declare function t:create-and-store-test-data-1()
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

declare function t:create-and-store-test-data-2()
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

declare function local:get-sample-result() {
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
                        <ab>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.1_1" type="token">Daß</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.1_2" type="token">alle</w>
                            <sic>unsere</sic>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.3_1" type="token">Erkenntnis</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.3_2" type="token">mit</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.3_3" type="token">der</w>
                            <surplus>einen</surplus>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.5_1" type="token">Erfahrung</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.5_2" type="token">anfange</w>
                            <supplied>,</supplied>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.2.7_1" type="token">daran</w>
                        </ab>
                        <milestone unit="sayings"/>
                        <ab>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.1_1" type="token">Wenn</w>
                            <unclear>aber</unclear>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_1" type="token">gleich</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_2" type="token">alle</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_3" type="token">unsere</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_4" type="token">Erkenntnis</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_5" type="token">mit</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_6" type="token">der</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_7" type="token">Erfahrung</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.3_8" type="token">anhebt</w>
                            <g>,</g>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.5_1" type="token">so</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.5_2" type="token">entspringt</w>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.5_3" type="token">sie</w>
                            <note>die Erkenntnis</note>
                            <w xml:id="t_Add_2020_N1.2.1.1.3.4.7_1" type="token">darum</w>
                            <w type="colophon">doch nicht eben</w>
                        </ab>
                        <milestone unit="second_narrative_section"/>
                        <ab>
                            <catchwords>Es ist also wenigstens eine der näheren Untersuchung noch benötigte und nicht auf den</catchwords>
                        </ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};
