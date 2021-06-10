xquery version "3.1";

module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons";

declare namespace http = "http://expath.org/ns/http-client";

declare variable $tc:server := "http://0.0.0.0:8080/exist/restxq";

declare function tc:is-endpoint-http200($url as xs:string) as xs:boolean {
    let $http-status := tc:get-http-status($url)
    return
        $http-status = "200"
};

declare function tc:get-http-status($url as xs:string) as xs:string {
    let $req := tc:make-request($url)
    return
        http:send-request($req)[1]/@status
};

declare function tc:make-request($url as xs:string)
as element() {
    <http:request href="{$url}" method="get">
        <http:header name="Connection" value="close"/>
   </http:request>
};

declare function tc:get-fragments()
as map(*) {
    map {
        "transcription": map {
            "82a": <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="karshuni">
                    <body xml:lang="karshuni">
                        <pb id="N1.4.2.4.4.2" facs="textgrid:3r1nz" n="82a" xml:id="a1"/>
                        <cb id="N1.4.2.4.4.4"/>
                        <head id="N1.4.2.4.4.6">
                            <seg id="N1.4.2.4.4.6.2" xml:lang="ara">
                                <supplied id="N1.4.2.4.4.6.2.3">.</supplied>
                                <add id="N1.4.2.4.4.6.2.5" place="margin">
                                    <w xml:id="Add_2020_N1.5.3.5.5.7.3.6.3_1" type="token">حقًا</w>
                                </add>
                            </seg>
                            <g id="N1.4.2.4.4.6.4">✓</g>
                            <hi id="N1.4.2.4.4.6.6" rend="color(red)">
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.3_1" type="token">܀</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.3_2" type="token">ܬܘܒ</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.3_3" type="token">ܒܚܹܝܠ</w>
                                <choice id="N1.4.2.4.4.6.6.3">
                                    <abbr id="N1.4.2.4.4.6.6.3.2">
                                        <w xml:id="Add_2020_N1.5.3.5.5.7.7.4.3.2_1" type="token">ܝܗ̈ܿ</w>
                                    </abbr>
                                    <expan id="N1.4.2.4.4.6.6.3.4">
                                        <w xml:id="Add_2020_N1.5.3.5.5.7.7.4.5.2_1" type="token">ܝܗ</w>
                                    </expan>
                                </choice>
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.5_1" type="token">ܟܿܬܒܢܐ</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.5_2" type="token">ܩܲܠܝܼܠ</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.5_3" type="token">ܡܼܢ</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.7.7.5_4" type="token">ܡ̈ܬܼܠܐ</w>
                                <persName id="N1.4.2.4.4.6.6.5">
                                    <w xml:id="Add_2020_N1.5.3.5.5.7.7.6.2_1" type="token">ܕܐܚܝܼܩܲܪ܆</w>
                                </persName>
                            </hi>
                        </head>
                        <ab id="N1.4.2.4.4.8">
                            <w xml:id="Add_2020_N1.5.3.5.5.9.2_1" type="token">الحكيم</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.9.2_2" type="token">الماهر</w>
                            <persName id="N1.4.2.4.4.8.2">
                                <w xml:id="Add_2020_N1.5.3.5.5.9.3.2_1" type="token">حيقار</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.5.5.9.4_1" type="token">الفارسي.</w>
                            <span id="N1.4.2.4.4.8.4-1" type="motif" n="successful_courtier" next="#N1.4.2.4.4.8.4-2">
                                <w xml:id="Add_2020_N1.5.3.5.5.9.5.5_1" type="token">وكان</w>
                            </span>
                        </ab>
                        <ab id="N1.4.2.4.4.9">
                            <span id="N1.4.2.4.4.8.4-2" type="motif" n="successful_courtier">
                                <w xml:id="Add_2020_N1.5.3.5.5.10.2.4_1" type="token">كاتب</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.10.2.4_2" type="token">الملك</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.10.2.4_3" type="token">ومتقدم</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.10.2.4_4" type="token">عنده</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.10.2.4_5" type="token">جدًا</w>
                            </span>
                            <w xml:id="Add_2020_N1.5.3.5.5.10.3_1" type="token">.</w>
                        </ab>
                        <ab id="N1.4.2.4.4.11">
                            <w xml:id="Add_2020_N1.5.3.5.5.12.2_1" type="token">ܢܒܬܕܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.12.2_2" type="token">ܒܥܘܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.12.2_3" type="token">ܐܠܒܐܪܝ</w>
                            <add id="N1.4.2.4.4.11.2" place="interlinear">
                                <w xml:id="Add_2020_N1.5.3.5.5.12.3.3_1" type="token">اختبار</w>
                            </add>
                            <w xml:id="Add_2020_N1.5.3.5.5.12.4_1" type="token">ܬܥܐܠܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.12.4_2" type="token">ܓܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.12.4_3" type="token">ܐܣܡܗ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.13">
                            <lb id="N1.4.2.4.4.13.2" break="no"/>
                            <w xml:id="Add_2020_N1.5.3.5.5.14.4_1" type="token">ܘܬܥܐܠܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.14.4_2" type="token">ܕܟܪܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.14.4_3" type="token">ܐܠܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.14.4_4" type="token">ܐܠܐܒܕ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.14.4_5" type="token">ܘܢܟܬܒ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.14.4_6" type="token">ܟܒܪ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.15">
                            <w xml:id="Add_2020_N1.5.3.5.5.16.2_1" type="token">ܐܠܚܟܝܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.16.2_2" type="token">ܐܠܡܐܗܪ</w>
                            <choice id="N1.4.2.4.4.15.2">
                                <sic id="N1.4.2.4.4.15.2.2">ܐܠܦܠܝܘܣ</sic>
                                <corr id="N1.4.2.4.4.15.2.4">
                                    <w xml:id="Add_2020_N1.5.3.5.5.16.3.5.2_1" type="token">ܐܠܦܠܝܣܘܦ</w>
                                </corr>
                            </choice>
                            <w xml:id="Add_2020_N1.5.3.5.5.16.4_1" type="token">ܐܠܫܐܛܪ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.17">
                            <w xml:id="Add_2020_N1.5.3.5.5.18.2_1" type="token">ܘܙܝܪ</w>
                            <persName id="N1.4.2.4.4.17.2">
                                <w xml:id="Add_2020_N1.5.3.5.5.18.3.2_1" type="token">ܣܢܚܐܪܝܒ</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.5.5.18.4_1" type="token">ܐܒܢ</w>
                            <persName id="N1.4.2.4.4.17.4">
                                <w xml:id="Add_2020_N1.5.3.5.5.18.5.2_1" type="token">ܣܪܚܐܘܕܡ</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.5.5.18.6_1" type="token">ܡܠܟ</w>
                            <placeName id="N1.4.2.4.4.17.6">
                                <w xml:id="Add_2020_N1.5.3.5.5.18.7.2_1" type="token">ܐܬܘܪ</w>
                            </placeName>
                        </ab>
                        <ab id="N1.4.2.4.4.19">
                            <placeName id="N1.4.2.4.4.19.2">
                                <w xml:id="Add_2020_N1.5.3.5.5.20.3.2_1" type="token">ܘܢܝܢܘܝ</w>
                            </placeName>
                            <placeName id="N1.4.2.4.4.19.4">
                                <w xml:id="Add_2020_N1.5.3.5.5.20.5.2_1" type="token">ܘܐܠܡܘܨܠ</w>
                            </placeName>
                            <w xml:id="Add_2020_N1.5.3.5.5.20.6_1" type="token">ܘܡܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.20.6_2" type="token">ܓܪܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.20.6_3" type="token">ܡܥܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.20.6_4" type="token">ܘܡܢ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.21">
                            <w xml:id="Add_2020_N1.5.3.5.5.22.2_1" type="token">ܐܒܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.2_2" type="token">ܐܟܬܗ</w>
                            <persName id="N1.4.2.4.4.21.2">
                                <w xml:id="Add_2020_N1.5.3.5.5.22.3.2_1" type="token">ܢܐܕܐܢ</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_1" type="token">.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_2" type="token">ܟܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_3" type="token">ܦܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_4" type="token">ܐܝܐܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_5" type="token">ܐܠܡܠܟ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_6" type="token">ܐܒܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.22.4_7" type="token">ܣܪܚܐܕܘܡ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.23">
                            <w xml:id="Add_2020_N1.5.3.5.5.24.2_1" type="token">ܡܠܟ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.24.2_2" type="token">ܐܪܜ</w>
                            <unclear id="N1.4.2.4.4.23.2" reason="illegible">
                                <placeName id="N1.4.2.4.4.23.2.3">ܐܬܘܪ</placeName>
                            </unclear>
                            <placeName id="N1.4.2.4.4.23.4">
                                <w xml:id="Add_2020_N1.5.3.5.5.24.5.2_1" type="token">ܘܢܝܢܘܝ</w>
                            </placeName>
                            <w xml:id="Add_2020_N1.5.3.5.5.24.6_1" type="token">ܘܒܠܐܕܗܐ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.24.6_2" type="token">ܪܓܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.24.6_3" type="token">ܚܟܝܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.24.6_4" type="token">ܝܩܐܠ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.25">
                            <w xml:id="Add_2020_N1.5.3.5.5.26.2_1" type="token">ܠܗ</w>
                            <persName id="N1.4.2.4.4.25.2">
                                <w xml:id="Add_2020_N1.5.3.5.5.26.3.2_1" type="token">ܚܝܩܐܪ</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.5.5.26.4_1" type="token">ܘܟܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.26.4_2" type="token">ܘܙܝܪ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.26.4_3" type="token">ܐܠܡܠܟ</w>
                            <persName id="N1.4.2.4.4.25.4">
                                <w xml:id="Add_2020_N1.5.3.5.5.26.5.2_1" type="token">ܣܢܚܐܪܝܒ</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.5.5.26.6_1" type="token">ܘܟܐܬܒܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.26.6_2" type="token">ܘܟܐܢ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.27">
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_1" type="token">ܕܘ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_2" type="token">ܡܐܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_3" type="token">ܓܙܝܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_4" type="token">ܘܪܙܩ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_5" type="token">ܟܬܝܪ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_6" type="token">ܘܟܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_7" type="token">ܡܐܗܪ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_8" type="token">ܚܟܝܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.28.2_9" type="token">ܦܝܠܣܘܦ</w>
                        </ab>
                        <cb id="N1.4.2.4.4.29"/>
                        <ab id="N1.4.2.4.4.31" type="head">
                            <seg id="N1.4.2.4.4.31.3" xml:lang="ara">
                                <w xml:id="Add_2020_N1.5.3.5.5.32.4.3_1" type="token">رأس</w>
                                <add id="N1.4.2.4.4.31.3.3" place="header">
                                    <w xml:id="Add_2020_N1.5.3.5.5.32.4.4.3_1" type="token">اختبار</w>
                                </add>
                                <w xml:id="Add_2020_N1.5.3.5.5.32.4.5_1" type="token">متقاطع</w>
                            </seg>
                        </ab>
                        <ab id="N1.4.2.4.4.33">
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_1" type="token">ܕܘ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_2" type="token">ܡܥܪܦܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_3" type="token">ܘܪܐܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_4" type="token">ܘܬܕܒܝܪ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_5" type="token">ܘܟܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_6" type="token">ܩܕ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_7" type="token">ܬܙܘܓ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_8" type="token">ܣܬܝܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.34.2_9" type="token">ܐܡܪܐܗ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.35">
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_1" type="token">ܘܒܢܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_2" type="token">ܠܟܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_3" type="token">ܘܐܚܕܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_4" type="token">ܡܢܗܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_5" type="token">ܡܩܨܘܪܗ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_6" type="token">ܘܡܥ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_7" type="token">ܗܕܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.36.2_8" type="token">ܟܠܗ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.37">
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_1" type="token">ܠܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_2" type="token">ܝܟܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_3" type="token">ܠܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_4" type="token">ܘܠܕ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_5" type="token">ܝܪܬܗ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_6" type="token">ܘܟܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_7" type="token">ܟܬܝܪ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_8" type="token">ܐܠܗܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_9" type="token">ܠܐܓܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.38.2_10" type="token">ܕܠܟ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.39">
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_1" type="token">ܘܐܢܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_2" type="token">ܦܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_3" type="token">ܕܐܬ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_4" type="token">ܝܘܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_5" type="token">ܓܡܥ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_6" type="token">ܐܠܡܢܓܡܝܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.40.2_7" type="token">ܘܐܠܣܚܪܗ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.41">
                            <w xml:id="Add_2020_N1.5.3.5.5.42.2_1" type="token">ܘܐܠܥܐܪܦܝܢ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.42.2_2" type="token">ܘܐܫܟܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.42.2_3" type="token">ܠܗܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.42.2_4" type="token">ܚܐܠܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.42.2_5" type="token">ܘܐܡܪ</w>
                            <choice id="N1.4.2.4.4.41.2">
                                <sic id="N1.4.2.4.4.41.2.2">ܒܥܩܘܪܝܬܗ</sic>
                                <corr id="N1.4.2.4.4.41.2.4">
                                    <w xml:id="Add_2020_N1.5.3.5.5.42.3.5.2_1" type="token">ܥܩܘܪܝܬܗ</w>
                                </corr>
                            </choice>
                            <choice id="N1.4.2.4.4.41.4">
                                <sic id="N1.4.2.4.4.41.4.2">ܒܥܩܘܪܝܬܗ</sic>
                                <corr id="N1.4.2.4.4.41.4.4" resp="#sb">
                                    <w xml:id="Add_2020_N1.5.3.5.5.42.5.5.3_1" type="token">ܥܩܘܪܝܬܗ</w>
                                </corr>
                            </choice>
                        </ab>
                        <ab id="N1.4.2.4.4.43">
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_1" type="token">ܦܩܐܠܘܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_2" type="token">ܠܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_3" type="token">ܐܕܟܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_4" type="token">ܐܕܒܚ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_5" type="token">ܠܠܐܠܗܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_6" type="token">ܘܐܣܬܓܝܪ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.44.2_7" type="token">ܒܗܡ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.45">
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_1" type="token">ܠܥܠܗܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_2" type="token">ܝܪܙܩܘܟ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_3" type="token">ܘܠܕܐ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_4" type="token">ܦܦܥܠ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_5" type="token">ܟܡܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_6" type="token">ܩܐܠܘܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_7" type="token">ܠܗ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.46.2_8" type="token">ܘܩܕܡ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.47">
                            <w xml:id="Add_2020_N1.5.3.5.5.48.2_1" type="token">ܐܠܩܪܐܒܝܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.48.2_2" type="token">ܠܠܐܨܢܐܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.48.2_3" type="token">ܘܐܣܬܓܐܬ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.48.2_4" type="token">ܒܗܡ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.48.2_5" type="token">ܘܬܜܪܥ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.48.2_6" type="token">ܐܠܝܗܡ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.49">
                            <w xml:id="Add_2020_N1.5.3.5.5.50.2_1" type="token">ܒܐܠܛܠܒܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.50.2_2" type="token">ܘܐܠܕܥܐ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.50.2_3" type="token">ܦܠܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.50.2_4" type="token">ܝܓܝܒܘܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.50.2_5" type="token">ܒܟܠܡܗ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.50.2_6" type="token">ܦܟܪܓ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.51">
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_1" type="token">ܝܚܙܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_2" type="token">ܢܕܡܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_3" type="token">ܟܐܝܒ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_4" type="token">ܘܐܢܨܪܦ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_5" type="token">ܡܬܐܠܡ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_6" type="token">ܐܠܩܠܒ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.52.2_7" type="token">ܘܪܓܥ</w>
                        </ab>
                        <ab id="N1.4.2.4.4.53">
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_1" type="token">ܒܐܠܬܜܪܥ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_2" type="token">ܐܠܝ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_3" type="token">ܐܠܠܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_4" type="token">ܬܥܐܠܝ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_5" type="token">ܘܐܡܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_6" type="token">ܘܐܣܬܥܐܢ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_7" type="token">ܒܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.54.2_8" type="token">ܒܚܪܩܗ̈</w>
                        </ab>
                        <ab id="N1.4.2.4.4.55">
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_1" type="token">ܩܠܒ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_2" type="token">ܩܐܝܠܐ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_3" type="token">ܝܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_4" type="token">ܐܠܐܗ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_5" type="token">ܐܠܣܡܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_6" type="token">ܘܐܠܐܪܜ.</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_7" type="token">ܝܐ</w>
                            <w xml:id="Add_2020_N1.5.3.5.5.56.2_8" type="token">ܟܐܠܩ</w>
                        </ab>
                        <lg id="N1.4.2.4.4.57">
                            <l id="N1.4.2.4.4.57.2">
                                <w xml:id="Add_2020_N1.5.3.5.5.58.3.2_1" type="token">ܩܠܒ</w>
                                <add id="N1.4.2.4.4.57.2.2" place="interlinear">
                                    <w xml:id="Add_2020_N1.5.3.5.5.58.3.3.3_1" type="token">اختبار</w>
                                </add>
                                <w xml:id="Add_2020_N1.5.3.5.5.58.3.4_1" type="token">ܩܐܝܠܐ</w>
                            </l>
                            <l id="N1.4.2.4.4.57.4">
                                <w xml:id="Add_2020_N1.5.3.5.5.58.5.2_1" type="token">ܩܠܒ</w>
                                <w xml:id="Add_2020_N1.5.3.5.5.58.5.2_2" type="token">ܩܐܝܠܐ</w>
                                <surplus id="N1.4.2.4.4.57.4.2">:</surplus>
                            </l>
                        </lg>
                        <ab id="N1.4.2.4.4.59" xml:lang="ara">
                            <seg id="N1.4.2.4.4.59.3" type="colophon">. نهاية<add id="N1.4.2.4.4.59.3.3" place="footer">اختبار</add>
                         النص</seg>
                            <w xml:id="Add_2020_N1.5.3.5.5.60.5_1" type="token">وماتت.</w>
                        </ab>
                        <ab id="N1.4.2.4.4.61">
                            <catchwords id="N1.4.2.4.4.61.2">الخلايق كلها</catchwords>
                        </ab>
                        <pb id="N1.4.2.4.4.63" facs="textgrid:3r1p0" n="82b"/>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
        },
        "transliteration": map {
            "82a": <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <text>
            <group>
                <text xml:lang="ara">
                    <body xml:lang="ara">
                        <pb id="N1.4.2.2.4.2" n="82a"/>
                        <cb id="N1.4.2.2.4.4"/>
                        <head id="N1.4.2.2.4.6">
                            <supplied id="N1.4.2.2.4.6.2">.</supplied>
                            <add id="N1.4.2.2.4.6.4" place="margin">
                                <w xml:id="Add_2020_N1.5.3.3.5.7.5.3_1" type="token">حقًا</w>
                            </add>
                            <w xml:id="Add_2020_N1.5.3.3.5.7.6_1" type="token">حيث</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.7.6_2" type="token">تبدأ</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.7.6_3" type="token">القصة</w>
                            <g id="N1.4.2.2.4.6.6">✓</g>
                        </head>
                        <ab id="N1.4.2.2.4.8">
                            <w xml:id="Add_2020_N1.5.3.3.5.9.2_1" type="token">الحاسوب</w>
                        </ab>
                        <ab id="N1.4.2.2.4.10">
                            <w xml:id="Add_2020_N1.5.3.3.5.11.2_1" type="token">نبتدي</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.11.2_2" type="token">بعون</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.11.2_3" type="token">الباري</w>
                            <add id="N1.4.2.2.4.10.2" place="interlinear">
                                <w xml:id="Add_2020_N1.5.3.3.5.11.3.3_1" type="token">اختبار</w>
                            </add>
                            <w xml:id="Add_2020_N1.5.3.3.5.11.4_1" type="token">تعالى</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.11.4_2" type="token">جل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.11.4_3" type="token">اسمه</w>
                        </ab>
                        <ab id="N1.4.2.2.4.12">
                            <lb id="N1.4.2.2.4.12.2" break="no"/>
                            <w xml:id="Add_2020_N1.5.3.3.5.13.4_1" type="token">وتعالى</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.13.4_2" type="token">ذكره</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.13.4_3" type="token">الى</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.13.4_4" type="token">الابد.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.13.4_5" type="token">ونكتب</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.13.4_6" type="token">خبر</w>
                        </ab>
                        <ab id="N1.4.2.2.4.14">
                            <w xml:id="Add_2020_N1.5.3.3.5.15.2_1" type="token">الحكيم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.15.2_2" type="token">الماهر</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.15.2_3" type="token">الفليوس</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.15.2_4" type="token">الشاطر</w>
                        </ab>
                        <ab id="N1.4.2.2.4.16">
                            <w xml:id="Add_2020_N1.5.3.3.5.17.2_1" type="token">وزير</w>
                            <persName id="N1.4.2.2.4.16.2">
                                <w xml:id="Add_2020_N1.5.3.3.5.17.3.2_1" type="token">سنحاريب</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.3.5.17.4_1" type="token">ابن</w>
                            <persName id="N1.4.2.2.4.16.4">
                                <w xml:id="Add_2020_N1.5.3.3.5.17.5.2_1" type="token">سرحادوم</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.3.5.17.6_1" type="token">ملك</w>
                            <unclear id="N1.4.2.2.4.16.6" reason="illegible">
                                <placeName id="N1.4.2.2.4.16.6.3">اتور</placeName>
                            </unclear>
                        </ab>
                        <milestone id="N1.4.2.2.4.18" unit="first_narrative_section"/>
                        <ab id="N1.4.2.2.4.20">
                            <placeName id="N1.4.2.2.4.20.2">
                                <w xml:id="Add_2020_N1.5.3.3.5.21.3.2_1" type="token">ونينوى</w>
                            </placeName>
                            <placeName id="N1.4.2.2.4.20.4">
                                <w xml:id="Add_2020_N1.5.3.3.5.21.5.2_1" type="token">والموصل</w>
                            </placeName>
                            <w xml:id="Add_2020_N1.5.3.3.5.21.6_1" type="token">.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.21.6_2" type="token">وما</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.21.6_3" type="token">جرا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.21.6_4" type="token">منه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.21.6_5" type="token">ومن</w>
                        </ab>
                        <ab id="N1.4.2.2.4.22">
                            <w xml:id="Add_2020_N1.5.3.3.5.23.2_1" type="token">ابن</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.2_2" type="token">اخته</w>
                            <persName id="N1.4.2.2.4.22.2">
                                <w xml:id="Add_2020_N1.5.3.3.5.23.3.2_1" type="token">نادان</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.4_1" type="token">.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.4_2" type="token">كان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.4_3" type="token">في</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.4_4" type="token">ايام</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.4_5" type="token">الملك</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.23.4_6" type="token">ابن</w>
                            <persName id="N1.4.2.2.4.22.4">
                                <w xml:id="Add_2020_N1.5.3.3.5.23.5.2_1" type="token">سرحادوم</w>
                            </persName>
                        </ab>
                        <ab id="N1.4.2.2.4.24">
                            <w xml:id="Add_2020_N1.5.3.3.5.25.2_1" type="token">ملك</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.25.2_2" type="token">ارض</w>
                            <placeName id="N1.4.2.2.4.24.2">
                                <w xml:id="Add_2020_N1.5.3.3.5.25.3.2_1" type="token">اتور</w>
                            </placeName>
                            <placeName id="N1.4.2.2.4.24.4">
                                <w xml:id="Add_2020_N1.5.3.3.5.25.5.2_1" type="token">ونينوى</w>
                            </placeName>
                            <w xml:id="Add_2020_N1.5.3.3.5.25.6_1" type="token">وبلادها.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.25.6_2" type="token">رجل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.25.6_3" type="token">حكيم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.25.6_4" type="token">يقال</w>
                        </ab>
                        <ab id="N1.4.2.2.4.26">
                            <w xml:id="Add_2020_N1.5.3.3.5.27.2_1" type="token">له</w>
                            <persName id="N1.4.2.2.4.26.2">
                                <w xml:id="Add_2020_N1.5.3.3.5.27.3.2_1" type="token">حيقار</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.3.5.27.4_1" type="token">.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.27.4_2" type="token">وكان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.27.4_3" type="token">وزير</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.27.4_4" type="token">الملك</w>
                            <persName id="N1.4.2.2.4.26.4">
                                <w xml:id="Add_2020_N1.5.3.3.5.27.5.2_1" type="token">سنحاريب</w>
                            </persName>
                            <w xml:id="Add_2020_N1.5.3.3.5.27.6_1" type="token">وكاتبه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.27.6_2" type="token">وكان</w>
                        </ab>
                        <ab id="N1.4.2.2.4.28">
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_1" type="token">ذو</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_2" type="token">مال</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_3" type="token">جزيل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_4" type="token">ورزق</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_5" type="token">كثير.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_6" type="token">وكان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_7" type="token">ماهر</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_8" type="token">حكيم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.29.2_9" type="token">فيلسوف</w>
                        </ab>
                        <ab id="N1.4.2.2.4.30">
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_1" type="token">ذو</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_2" type="token">معرفه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_3" type="token">وراي</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_4" type="token">وتدبير.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_5" type="token">وكان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_6" type="token">قد</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_7" type="token">تزوج</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_8" type="token">ستين</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.31.2_9" type="token">امراه</w>
                        </ab>
                        <milestone id="N1.4.2.2.4.32" unit="second_narrative_section"/>
                        <cb id="N1.4.2.2.4.34"/>
                        <ab id="N1.4.2.2.4.36" type="head">
                            <w xml:id="Add_2020_N1.5.3.3.5.37.3_1" type="token">رأس</w>
                            <add id="N1.4.2.2.4.36.3" place="header">
                                <w xml:id="Add_2020_N1.5.3.3.5.37.4.3_1" type="token">اختبار</w>
                            </add>
                            <w xml:id="Add_2020_N1.5.3.3.5.37.5_1" type="token">متقاطع</w>
                        </ab>
                        <ab id="N1.4.2.2.4.38">
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_1" type="token">وبنى</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_2" type="token">لكل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_3" type="token">واحده</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_4" type="token">منهن</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_5" type="token">مقصوره.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_6" type="token">ومع</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_7" type="token">هذا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.39.2_8" type="token">كله</w>
                        </ab>
                        <ab id="N1.4.2.2.4.40">
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_1" type="token">لم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_2" type="token">يكن</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_3" type="token">له</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_4" type="token">ولد</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_5" type="token">يرثه.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_6" type="token">وكان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_7" type="token">كثير</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_8" type="token">الهم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_9" type="token">لاجل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.41.2_10" type="token">ذلك</w>
                        </ab>
                        <ab id="N1.4.2.2.4.42">
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_1" type="token">وانه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_2" type="token">في</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_3" type="token">ذات</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_4" type="token">يوم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_5" type="token">جمع</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_6" type="token">المنجمين</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.43.2_7" type="token">والسحره</w>
                        </ab>
                        <ab id="N1.4.2.2.4.44">
                            <w xml:id="Add_2020_N1.5.3.3.5.45.2_1" type="token">والعارفين.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.45.2_2" type="token">واشكا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.45.2_3" type="token">لهم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.45.2_4" type="token">حاله</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.45.2_5" type="token">وامر</w>
                            <choice id="N1.4.2.2.4.44.2">
                                <sic id="N1.4.2.2.4.44.2.2">بعقوريته</sic>
                                <corr id="N1.4.2.2.4.44.2.4">
                                    <w xml:id="Add_2020_N1.5.3.3.5.45.3.5.2_1" type="token">عقوريته</w>
                                </corr>
                            </choice>
                            <choice id="N1.4.2.2.4.44.4">
                                <sic id="N1.4.2.2.4.44.4.2">بعقوريته</sic>
                                <corr id="N1.4.2.2.4.44.4.4" resp="#sb">
                                    <w xml:id="Add_2020_N1.5.3.3.5.45.5.5.3_1" type="token">عقوريته</w>
                                </corr>
                            </choice>
                        </ab>
                        <ab id="N1.4.2.2.4.46">
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_1" type="token">فقالوا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_2" type="token">له</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_3" type="token">ادخل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_4" type="token">ادبح</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_5" type="token">للالهه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_6" type="token">واستجير</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.47.2_7" type="token">بهم</w>
                        </ab>
                        <ab id="N1.4.2.2.4.48">
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_1" type="token">لعلهم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_2" type="token">يرزقوك</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_3" type="token">ولدًا.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_4" type="token">ففعل</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_5" type="token">كما</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_6" type="token">قالوا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_7" type="token">له.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.49.2_8" type="token">وقدم</w>
                        </ab>
                        <ab id="N1.4.2.2.4.50">
                            <w xml:id="Add_2020_N1.5.3.3.5.51.2_1" type="token">القرابين</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.51.2_2" type="token">للاصنام</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.51.2_3" type="token">واستغاث</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.51.2_4" type="token">بهم.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.51.2_5" type="token">وتضرّع</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.51.2_6" type="token">اليهم</w>
                        </ab>
                        <ab id="N1.4.2.2.4.52">
                            <w xml:id="Add_2020_N1.5.3.3.5.53.2_1" type="token">بالطلبه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.53.2_2" type="token">والدعا.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.53.2_3" type="token">فلم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.53.2_4" type="token">يجيبوه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.53.2_5" type="token">بكلمه.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.53.2_6" type="token">فخرج</w>
                        </ab>
                        <ab id="N1.4.2.2.4.54">
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_1" type="token">يحزان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_2" type="token">ندمان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_3" type="token">خايب</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_4" type="token">وانصرف</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_5" type="token">متالم</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_6" type="token">القلب.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.55.2_7" type="token">ورجع</w>
                        </ab>
                        <ab id="N1.4.2.2.4.56">
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_1" type="token">بالتضرع</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_2" type="token">الى</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_3" type="token">الله</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_4" type="token">تعالى.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_5" type="token">وامن</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_6" type="token">واستعان</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_7" type="token">به</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.57.2_8" type="token">بحرقة</w>
                        </ab>
                        <ab id="N1.4.2.2.4.58">
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_1" type="token">قلب</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_2" type="token">قايلًا.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_3" type="token">يا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_4" type="token">الاه</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_5" type="token">السما</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_6" type="token">والارض.</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_7" type="token">يا</w>
                            <w xml:id="Add_2020_N1.5.3.3.5.59.2_8" type="token">خالق</w>
                        </ab>
                        <lg id="N1.4.2.2.4.60">
                            <l id="N1.4.2.2.4.60.2">
                                <w xml:id="Add_2020_N1.5.3.3.5.61.3.2_1" type="token">هل</w>
                                <add id="N1.4.2.2.4.60.2.2" place="below">
                                    <w xml:id="Add_2020_N1.5.3.3.5.61.3.3.3_1" type="token">اختبار</w>
                                </add>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.3.4_1" type="token">أقارنك</w>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.3.4_2" type="token">بيوم</w>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.3.4_3" type="token">صيفي؟</w>
                            </l>
                            <l id="N1.4.2.2.4.60.4">
                                <w xml:id="Add_2020_N1.5.3.3.5.61.5.2_1" type="token">انت</w>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.5.2_2" type="token">أكثر</w>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.5.2_3" type="token">جميلة</w>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.5.2_4" type="token">وأكثر</w>
                                <w xml:id="Add_2020_N1.5.3.3.5.61.5.2_5" type="token">اعتدالا</w>
                                <surplus id="N1.4.2.2.4.60.4.2">:</surplus>
                            </l>
                        </lg>
                        <ab id="N1.4.2.2.4.62">
                            <seg id="N1.4.2.2.4.62.2" type="colophon">. نهاية<add id="N1.4.2.2.4.62.2.3" place="footer">اختبار</add>
                      النص</seg>
                            <w xml:id="Add_2020_N1.5.3.3.5.63.4_1" type="token">وماتت.</w>
                        </ab>
                        <pb id="N1.4.2.2.4.64" n="82b"/>
                    </body>
                </text>
            </group>
        </text>
    </TEI>
        }
    }
};