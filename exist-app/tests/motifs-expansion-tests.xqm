xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0.1/functx/functx.xq";
import module namespace me="http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion" at "../modules/motifs-expansion.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:assertTrue
function t:simple-annotations-one-line() {
    let $result := t:get-test-data-simple-annotations-one-line()
        => me:main()
        => local:prepare-for-comparison()
    let $reference := t:get-goal-data-simple-annotations-one-line()
        => local:prepare-for-comparison()
    return
        $result = $reference
};

declare
    %test:assertTrue
function t:simple-annotations-two-lines() {
    let $result := t:get-test-data-simple-annotations-two-lines()
        => me:main()
        => local:prepare-for-comparison()
    let $reference := t:get-goal-data-simple-annotations-two-lines()
        => local:prepare-for-comparison()
    return
        $result = $reference
};

declare
    %test:assertTrue
function t:simple-annotations-multiple-lines() {
    let $result := t:get-test-data-simple-annotations-multiple-lines()
        => me:main()
        => local:prepare-for-comparison()
    let $reference := t:get-goal-data-simple-annotations-multiple-lines()
        => local:prepare-for-comparison()
    return
        $result = $reference
};

declare
    %test:assertTrue
function t:is-node-in-motif-true() {
    let $node := t:get-test-data-simple-annotations-one-line()//tei:persName
    return
        me:is-node-in-motif($node)
};

declare
    %test:assertTrue
function t:is-node-in-motif-true-ab() {
    let $node := t:get-test-data-simple-annotations-multiple-lines()//tei:ab[3]
    return
        me:is-node-in-motif($node)
};

declare
    %test:assertFalse
function t:is-node-in-motif-false-1() {
    let $node := t:get-test-data-simple-annotations-one-line()//tei:milestone
    return
        me:is-node-in-motif($node)
};

declare
    %test:assertFalse
function t:is-node-in-motif-false-2() {
    let $node := t:get-test-data-simple-annotations-two-lines()//tei:ab[3]/text()[last()]
    return
        me:is-node-in-motif($node)
};

declare
    %test:assertFalse
function t:is-node-in-motif-false-ab() {
    let $node := t:get-test-data-simple-annotations-multiple-lines()//tei:ab[2]
    return
        me:is-node-in-motif($node)
};

declare
    %test:assertTrue
function t:is-motif-one-liner-true() {
    let $node := t:get-test-data-simple-annotations-one-line()//processing-instruction('oxy_comment_start')
    return
        me:is-motif-one-liner($node)
};

declare
    %test:assertFalse
function t:is-motif-one-liner-false() {
    let $node := t:get-test-data-simple-annotations-two-lines()//processing-instruction('oxy_comment_start')
    return
        me:is-motif-one-liner($node)
};

declare function t:get-test-data-simple-annotations-one-line()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <pb n="293r"/>
                        <cb n="2"/>
                        <ab>نبتدي بعون الله ونكتب</ab>
                        <ab>قصة <?oxy_comment_start author="aelrefa" timestamp="20200827T090537+0200" comment="loyal_obligation_gods"?><persName>حيقار</persName> الحاكيم وكان فى<?oxy_comment_end?></ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function t:get-goal-data-simple-annotations-one-line()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <pb n="293r"/>
                        <cb n="2"/>
                        <ab>نبتدي بعون الله ونكتب</ab>
                        <ab>قصة <span type="motif" n="loyal_obligation_gods"><persName>حيقار</persName> الحاكيم وكان فى</span></ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function t:get-test-data-simple-annotations-two-lines()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <pb n="293r"/>
                        <cb n="2"/>
                        <ab>نبتدي بعون الله ونكتب</ab>
                        <ab>قصة <?oxy_comment_start author="aelrefa" timestamp="20200827T090537+0200" comment="loyal_obligation_gods"?><persName>حيقار</persName> الحاكيم وكان فى</ab>
                        <ab>للالهة<?oxy_comment_end?> وقلتوا لهم ارزقونى</ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function t:get-goal-data-simple-annotations-two-lines()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <pb n="293r"/>
                        <cb n="2"/>
                        <ab>نبتدي بعون الله ونكتب</ab>
                        <ab>قصة <span id="N1.1.1.1.3.5.2-1" type="motif" n="loyal_obligation_gods" next="#N1.1.1.1.3.5.2-2"><persName>حيقار</persName> الحاكيم وكان فى</span></ab>
                        <ab><span id="N1.1.1.1.3.5.2-2" type="motif" n ="loyal_obligation_gods">للالهة</span> وقلتوا لهم ارزقونى</ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function t:get-test-data-simple-annotations-multiple-lines()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <pb n="293r"/>
                        <cb n="2"/>
                        <ab>نبتدي بعون الله ونكتب</ab>
                        <ab>قصة <?oxy_comment_start author="aelrefa" timestamp="20200827T090537+0200" comment="loyal_obligation_gods"?><persName>حيقار</persName> الحاكيم وكان فى</ab>
                        <ab>يدفني ولم يجيبوه الالهة.</ab>
                        <ab>للالهة<?oxy_comment_end?> وقلتوا لهم ارزقونى</ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function t:get-goal-data-simple-annotations-multiple-lines()
as element(tei:TEI) {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <milestone unit="first_narrative_section"/>
                        <pb n="293r"/>
                        <cb n="2"/>
                        <ab>نبتدي بعون الله ونكتب</ab>
                        <ab>قصة <span id="N1.1.1.1.3.5.2-1" type="motif" n="loyal_obligation_gods" next="#N1.1.1.1.3.5.2-2"><persName>حيقار</persName> الحاكيم وكان فى</span></ab>
                        <ab><span id="N1.1.1.1.3.5.2-2" type="motif" n ="loyal_obligation_gods" next="#N1.1.1.1.3.5.2-3">يدفني ولم يجيبوه الالهة.</span></ab>
                        <ab><span id="N1.1.1.1.3.5.2-3" type="motif" n ="loyal_obligation_gods">للالهة</span> وقلتوا لهم ارزقونى</ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function local:prepare-for-comparison($nodes as node())
as xs:string {
    serialize($nodes)
    => replace("[\t\r\n]", "")
    => replace("\s+", " ")
};
