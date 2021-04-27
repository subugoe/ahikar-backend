xquery version "3.1";

module namespace t="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants/tests";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace vars="http://ahikar.sub.uni-goettingen.de/ns/annotations/variants" at "../modules/AnnotationAPI/annotations-variants.xqm";

declare variable $t:sample-map :=
    map {
        "variants": (map {
            "entry": "ܐܘ",
            "witness": "430"
        },map {
            "entry": "ܕܐܚܛܛ",
            "witness": "syr_422"
        },map {
            "entry": [],
            "witness": "syr_611"
        },map {
            "entry": [],
            "witness": "syr_612"
        }),
        "current": map {
            "t": "ܐܡܪ",
            "id": "syr_434_N4.4.2.6.4.8.1.3_1"
        }
    };
    
declare variable $t:sample-file :=
    util:binary-doc("/db/apps/ahikar/data/collation-results/ara-karshuni_Sbath_25_Vat_sir_424_Vat_sir_199_parables_result.json")
    => util:base64-decode()
    => parse-json();

declare
    %test:args("sample_teixml", "82a") %test:assertXPath("count($result) = 349")
function t:get-token-ids-on-page($teixml-uri as xs:string,
    $page as xs:string)
as xs:string+ {
    vars:get-token-ids-on-page($teixml-uri, $page)
};


declare
    %test:args("sample_teixml") %test:assertEquals("Add_2020")
function t:get-ms-id-from-idno($teixml-uri as xs:string)
as xs:string {
    vars:get-ms-id-from-idno($teixml-uri)
};

declare 
    %test:args("Sachau_336") %test:assertXPath("count($result) = 5")
function t:get-relevant-files($ms-id as xs:string)
as item()+ {
    vars:get-relevant-files($ms-id)
};

declare
    %test:args("Ar_7/229") %test:assertEquals("4")
function t:determine-id-position($ms-id as xs:string)
as xs:integer {
    let $json := vars:get-relevant-files($ms-id)
    return
        vars:determine-id-position($ms-id, $json[1])
};

declare
    %test:assertEquals("Variant")
function t:get-body-object() {
    vars:get-body-object($t:sample-map)
    => map:get("x-content-type")
};

declare
    %test:assertXPath("count($result) = 2")
function t:get-files-relevant-for-page() {
    let $relevant-files-for-ms-id := vars:get-relevant-files("Sbath_25")
    let $ms-id-position := 1
    let $tokens := ("Sbath_25_N4.4.2.4.4.2552.1_1", "Sbath_25_N4.4.2.4.4.500.1_1")
    return
        vars:get-files-relevant-for-page($relevant-files-for-ms-id, $ms-id-position, $tokens)
};

declare
    %test:assertEquals("1")
function t:get-indices-relevant-for-page() {
    let $table :=
        $t:sample-file
        => map:get("table")
    let $no-of-sequences := array:size($table)
    let $ms-id-position := 1
    let $tokens := ("Sbath_25_N4.4.2.4.4.2276.1_1", "Sbath_25_N4.4.2.4.4.2276.2.1_1", "Sbath_25_N4.4.2.4.4.2276.3_1", "Sbath_25_N4.4.2.4.4.2276.3_2", "Sbath_25_N4.4.2.4.4.2276.3_3")
    return
        vars:get-indices-relevant-for-page($table, $no-of-sequences, $ms-id-position, $tokens)
};

declare
    %test:assertXPath("count($result) = 2 and $result = (2, 3)")
function t:get-non-ms-id-positions-in-array() {
    vars:get-non-ms-id-positions-in-array($t:sample-file, 1)
};

declare
    %test:assertXPath("$result = ('ܕܐܚܛܛ', 'N')")
function t:get-target-information() {
    vars:make-annotation-value($t:sample-map)[2]
    => map:get("entry"),
    vars:make-annotation-value($t:sample-map)[2]
    => map:get("witness")
};

declare
    %test:assertEquals("ara")
function t:get-target-language() {
    vars:get-target-language("kant_sample_teixml")
};

declare
    %test:assertEquals("Sbath_25")
function t:get-witness() {
    vars:get-witness($t:sample-file, 1)
};

declare
    %test:assertEquals("5")
function t:get-witness-entry() {
    let $table :=
        $t:sample-file
        => map:get("table")
    let $entry-no := "1"
    let $witness-position := "1"
    return
        vars:get-witness-entry($table, $entry-no, $witness-position)
        => array:size()
};

declare
    %test:assertEquals("D")
function t:make-annotation-value() {
    vars:make-annotation-value($t:sample-map)[1]
    => map:get("witness")
};

declare
    %test:assertXPath("$result = ('Sbath_25_N4.4.2.4.4.2276.3_3', 'Vat_sir_424', 'Vat_sir_199')")
function t:make-map-for-token() {
    let $table := map:get($t:sample-file, "table")
    let $entry-pos := 1
    let $ms-id-position := 1
    let $non-ms-id-positions := (2, 3)
    let $current := 
        vars:make-map-for-token($t:sample-file, $table, $entry-pos, $ms-id-position, $non-ms-id-positions)
        => map:get("current")
        => map:get("id")
    let $variants := 
        vars:make-map-for-token($t:sample-file, $table, $entry-pos, $ms-id-position, $non-ms-id-positions)
        => map:get("variants")
    return
        (
            $current,
            $variants[1] => map:get("witness"),
            $variants[2] => map:get("witness")
            
        )
        
};