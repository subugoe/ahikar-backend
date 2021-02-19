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
    let $src-TEI := local:get-sample-tei()
    let $target-TEI := local:get-sample-result()
    return
        deep-equal(tokenize:main($src-TEI), $target-TEI)
};

declare
    %test:assertEquals("Add_2020")
function t:get-id-prefix()
as xs:string {
    let $TEI := local:get-sample-tei()
    return
        tokenize:get-id-prefix($TEI)
};

declare
    %test:assertXPath("$result/local-name() = 'ab' and count($result//text()) = 2 ")
function t:add-ids-single-node()
as node()* {
    let $node := <ab xmlns="http://www.tei-c.org/ns/1.0">some text</ab>
    let $id-prefix := "Add_2020"
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
        and $result/local-name() = 'seg'
        and $result[1]/@xml:id = 'Add_2020_N1.1_1'
        and $result[2]/@xml:id = 'Add_2020_N1.1_2' ")
function t:add-id-to-text()
as element(tei:seg)+ {
    let $node := <ab xmlns="http://www.tei-c.org/ns/1.0">some text </ab>
    let $id-prefix := "Add_2020"
    return
        tokenize:add-id-to-text($node/text(), $id-prefix)
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
                        <ab>Wenn <unclear>aber</unclear> gleich alle unsere Erkenntnis mit der Erfahrung anhebt<g>,</g> so entspringt sie<note>die Erkenntnis</note> darum <seg type="colophon">doch nicht eben</seg></ab>
                        
                        
                        <milestone unit="second_narrative_section"/>
                        <ab><catchwords>Es ist also wenigstens eine der näheren Untersuchung noch benötigte und nicht auf den</catchwords></ab> 
                    </body>
                </text>
            </group>
        </text>
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
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.1_1" type="token">Daß</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.1_2" type="token">alle</seg>
                            <sic>unsere</sic>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.3_1" type="token">Erkenntnis</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.3_2" type="token">mit</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.3_3" type="token">der</seg>
                            <surplus>einen</surplus>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.5_1" type="token">Erfahrung</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.5_2" type="token">anfange</seg>
                            <supplied>,</supplied>
                            <seg xml:id="Add_2020_N1.2.1.1.3.2.7_1" type="token">daran</seg>
                        </ab>
                        <milestone unit="sayings"/>
                        <ab>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.1_1" type="token">Wenn</seg>
                            <unclear>aber</unclear>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_1" type="token">gleich</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_2" type="token">alle</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_3" type="token">unsere</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_4" type="token">Erkenntnis</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_5" type="token">mit</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_6" type="token">der</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_7" type="token">Erfahrung</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.3_8" type="token">anhebt</seg>
                            <g>,</g>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.5_1" type="token">so</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.5_2" type="token">entspringt</seg>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.5_3" type="token">sie</seg>
                            <note>die Erkenntnis</note>
                            <seg xml:id="Add_2020_N1.2.1.1.3.4.7_1" type="token">darum</seg>
                            <seg type="colophon">doch nicht eben</seg>
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
