xquery version "3.1";

(: 
 : This module contains the unit tests for tei2html.xqm. 
 :)

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/tokenize/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "../modules/tokenize.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

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
