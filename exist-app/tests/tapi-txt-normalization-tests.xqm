xquery version "3.1";

module namespace ttnt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization/tests";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace norm="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization" at "../modules/tapi-txt-normalization.xqm";

declare
    %test:args("ܬܟܼܫܪ") %test:assertXPath("$result != 1852")
    %test:args("ܬܟܫܪ") %test:assertXPath("$result = 1823")
    %test:args("ܕܩܿܐܡ") %test:assertXPath("$result != 1855")
function ttnt:remove-codepoints($string as xs:string)
as xs:integer+ {
    let $codepoints := string-to-codepoints($string)
    return
        norm:remove-codepoints($codepoints)
};

declare
    %test:args("1825, 1834, 1815") %test:assertEquals("ܡܪܗ")
function ttnt:restore-text-from-codepoints($codepoints as xs:string)
as xs:string{
    let $codepoints-tmp := tokenize($codepoints, ", ")
    let $codepoints-to-int :=
        for $cp in $codepoints-tmp return
            xs:integer($cp)
    return
    norm:restore-text-from-codepoints($codepoints-to-int)
};
