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
function t:get-test-data-simple-spanning-over-pages() {
    let $result := t:get-test-data-simple-spanning-over-pages()
        => me:main()
        => local:prepare-for-comparison()
    let $reference := t:get-goal-data-simple-spanning-over-pages()
        => local:prepare-for-comparison()
    return
        $result = $reference
};

declare
    %test:assertTrue
function t:simple-1() {
    let $result := t:get-sample-data-simple-1()
        => me:main()
        => local:prepare-for-comparison()
    let $reference := t:get-goal-data-simple-1()
        => local:prepare-for-comparison()
    return
        $result = $reference
};


declare
    %test:assertTrue
function t:is-node-in-motif-true() {
    let $transform := t:get-test-data-simple-annotations-one-line() => me:transform-pis()
    let $node := $transform//tei:persName
    return
        me:is-node-in-motif($node)
};

declare
    %test:assertTrue
function t:is-node-in-motif-true-ab() {
    let $transform := t:get-test-data-simple-annotations-multiple-lines() => me:transform-pis()
    let $node := $transform//tei:ab[3]
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
    let $transform := t:get-test-data-simple-annotations-one-line() => me:transform-pis()
    let $node := $transform//tei:motif[@type = "start"]
    return
        me:is-motif-one-liner($node)
};

declare
    %test:assertFalse
function t:is-motif-one-liner-false() {
    let $transform := t:get-test-data-simple-annotations-two-lines() => me:transform-pis()
    let $node := $transform//tei:motif[@type = "start"]
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

declare function t:get-test-data-simple-spanning-over-pages() {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                       <ab>لا تفرح ولا تسرَّ <hi rendition="#red">يا بني</hi>
                          <?oxy_comment_start author="aelrefa" timestamp="20200625T112112+0200" comment="temptress_women"?>لا
                          تقرب الي</ab>
                       <ab>امراه مخاصمه صياحه. ولا يعجبك</ab>
                       <ab>حسن الامراه السفيها لان جمال</ab>
                       <ab>وهى العقل والحيا <hi rendition="#red">يا بني</hi> مثل مراود</ab>
                       <pb facs="textgrid:3r19m" n="8a" xml:id="a13"/>
                       <ab>والكلام<?oxy_comment_end?> يا بني اذا باداك عدوك</ab>
                   </body>
               </text>
           </group>
       </text>
   </TEI>
};

declare function t:get-goal-data-simple-spanning-over-pages-interformat() {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                       <ab>لا تفرح ولا تسرَّ <hi rendition="#red">يا بني</hi>
                       <motif type="start" n="temptress_women"/>لا
                          تقرب الي</ab>
                       <ab>امراه مخاصمه صياحه. ولا يعجبك</ab>
                       <ab>حسن الامراه السفيها لان جمال</ab>
                       <ab>وهى العقل والحيا <hi rendition="#red">يا بني</hi> مثل مراود</ab>
                       <pb facs="textgrid:3r19m" n="8a" xml:id="a13"/>
                       <ab>والكلام<motif type="end"/> يا بني اذا باداك عدوك</ab>
                   </body>
               </text>
           </group>
       </text>
   </TEI>
};

declare function t:get-goal-data-simple-spanning-over-pages() {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara" type="transliteration">
                    <body>
                        <ab>لا تفرح ولا تسرَّ <hi rendition="#red">يا بني</hi>
                            <span id="N1.1.1.1.3.1.3-1" type="motif" n="temptress_women" next="#N1.1.1.1.3.1.3-2">لا
                              تقرب الي</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.1.3-2" type="motif" n="temptress_women" next="#N1.1.1.1.3.1.3-3">امراه مخاصمه صياحه. ولا يعجبك</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.1.3-3" type="motif" n="temptress_women" next="#N1.1.1.1.3.1.3-4">حسن الامراه السفيها لان جمال</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.1.3-4" type="motif" n="temptress_women" next="#N1.1.1.1.3.1.3-5">وهى العقل والحيا <hi rendition="#red">يا بني</hi> مثل مراود</span>
                        </ab>
                        <pb facs="textgrid:3r19m" n="8a" xml:id="a13"/>
                        <ab>
                            <span id="N1.1.1.1.3.1.3-5" type="motif" n="temptress_women">والكلام</span> يا بني اذا باداك عدوك</ab>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
};

declare function t:get-sample-data-simple-1() {
<TEI xmlns="http://www.tei-c.org/ns/1.0">
   <text>
      <group>
         <text type="transcription" xml:lang="ara">
            <body>
               <milestone unit="first_narrative_section"/>
               <pb facs="textgrid:3r19d" n="2a" xml:id="a1"/>
               <ab>
                  <hi rendition="#red">نبتدي بعون الله وحسن</hi>
               </ab>
               <ab>
                  <hi rendition="#red">توفيقه ونكتب قصت<persName>حيقار</persName>
                  </hi>
               </ab>
               <ab>
                  <hi rendition="#red">الحكيم الفارسي الفيلسوف الماهر</hi>
               </ab>
               <ab>
                  <hi rendition="#red">الذي كان علي ايام<persName>سنحاريب</persName>
                  </hi>
               </ab>
               <ab>
                  <hi rendition="#red">الملك ملك<placeName>الموصل</placeName>
                  </hi>
               </ab>
               <ab>كان في ايام <persName>سنحاريب</persName> ابن</ab>
               <ab>
                  <persName>سرحادوم</persName> ملك <placeName>اتور</placeName>
                  <placeName>ونينوا</placeName>
               </ab>
               <ab>الحكيم الماهر <persName>حيقار</persName> الفارسي.
                  <?oxy_comment_start author="aelrefa" timestamp="20200625T101505+0200" comment="successful_courtier"?>وكان</ab>
               <ab>كاتب الملك ومتقدم عنده جدًا<?oxy_comment_end?>.</ab>
               <ab>فلما كان شاب. حكمت لهُ المنجمين</ab>
               <ab>بانه لم يرزق ولدًا. وكان لهُ</ab>
               <ab>مال كثير ورزق عظيم. وتزوج</ab>
               <ab>ستين امراه. وبني لهم ستين</ab>
               <ab>مقصوره. وكبر <persName>حيقار</persName> حتي</ab>
               <ab>بقي ابن ستين سنة. ولم يرزق</ab>
               <pb facs="textgrid:3r19d" n="2b" xml:id="a2"/>
               <ab>ولدًا. حينيدًا
                  <?oxy_comment_start author="aelrefa" timestamp="20200625T104444+0200" comment="loyal_obligation_gods"?>تقدم
                  الي الالهه الذين</ab>
               <ab>هم الاصنام. ودبح لهم الدبايح والقرابين</ab>
               <ab>وبخرهم بالقرفه واللبان. والعود</ab>
               <ab>الفاخر المعطر<?oxy_comment_end?>. وقال لهم يا ايها</ab>
               <ab>الالهه. اريد منكم انكم ترزقوني</ab>
            </body>
         </text>
      </group>
   </text>
</TEI>
};

declare function t:get-goal-data-simple-1() {
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
       <text>
          <group>
             <text type="transcription" xml:lang="ara">
                <body>
                   <milestone unit="first_narrative_section"/>
                   <pb facs="textgrid:3r19d" n="2a" xml:id="a1"/>
                   <ab>
                      <hi rendition="#red">نبتدي بعون الله وحسن</hi>
                   </ab>
                   <ab>
                      <hi rendition="#red">توفيقه ونكتب قصت<persName>حيقار</persName>
                      </hi>
                   </ab>
                   <ab>
                      <hi rendition="#red">الحكيم الفارسي الفيلسوف الماهر</hi>
                   </ab>
                   <ab>
                      <hi rendition="#red">الذي كان علي ايام<persName>سنحاريب</persName>
                      </hi>
                   </ab>
                   <ab>
                      <hi rendition="#red">الملك ملك<placeName>الموصل</placeName>
                      </hi>
                   </ab>
                   <ab>كان في ايام <persName>سنحاريب</persName> ابن</ab>
                   <ab>
                      <persName>سرحادوم</persName> ملك <placeName>اتور</placeName>
                      <placeName>ونينوا</placeName>
                   </ab>
                   <ab>الحكيم الماهر <persName>حيقار</persName> الفارسي.
                      <span id="N1.1.1.1.3.10.4-1" type="motif" n="successful_courtier" next="#N1.1.1.1.3.10.4-2">وكان</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.10.4-2" type="motif" n="successful_courtier">كاتب الملك ومتقدم عنده جدًا</span>.</ab>
                   <ab>فلما كان شاب. حكمت لهُ المنجمين</ab>
                   <ab>بانه لم يرزق ولدًا. وكان لهُ</ab>
                   <ab>مال كثير ورزق عظيم. وتزوج</ab>
                   <ab>ستين امراه. وبني لهم ستين</ab>
                   <ab>مقصوره. وكبر <persName>حيقار</persName> حتي</ab>
                   <ab>بقي ابن ستين سنة. ولم يرزق</ab>
                   <pb facs="textgrid:3r19d" n="2b" xml:id="a2"/>
                   <ab>ولدًا. حينيدًا
                      <span id="N1.1.1.1.3.19.2-1" type="motif" n="loyal_obligation_gods" next="#N1.1.1.1.3.19.2-2">تقدم
                      الي الالهه الذين</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.19.2-2" type="motif" n="loyal_obligation_gods" next="#N1.1.1.1.3.19.2-3">هم الاصنام. ودبح لهم الدبايح والقرابين</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.19.2-3" type="motif" n="loyal_obligation_gods" next="#N1.1.1.1.3.19.2-4">وبخرهم بالقرفه واللبان. والعود</span>
                        </ab>
                        <ab>
                            <span id="N1.1.1.1.3.19.2-4" type="motif" n="loyal_obligation_gods">الفاخر المعطر</span>. وقال لهم يا ايها</ab>
                   <ab>الالهه. اريد منكم انكم ترزقوني</ab>
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
