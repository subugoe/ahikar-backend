xquery version "3.1";

module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(:
 : Desired output:
 : 
 : {:)
(:  "witnesses" : [:)
(:    {:)
(:      "id" : "A",:)
(:      "tokens" : [:)
(:          { "t" : "A", "id" : "123" },:)
(:          { "t" : "black" , "id" : "asdf" },:)
(:          { "t" : "cat", "id" : "xyz" }:)
(:      ]:)
(:    },:)
(:    {:)
(:      "id" : "B",:)
(:      "tokens" : [:)
(:          { "t" : "A" },:)
(:          { "t" : "white" , "id" : "qwert" },:)
(:          { "t" : "kitten.", "id" : "qwert2" }:)
(:      ]:)
(:    }:)
(:  ]:)
(:}:)


declare variable $tei2json:textgrid := "/db/data/textgrid";
declare variable $tei2json:data := $tei2json:textgrid || "/data";
declare variable $tei2json:json := $tei2json:textgrid || "/json";
declare variable $tei2json:milestone-types :=
    ("first_narrative_section",
    "sayings",
    "second_narrative_section",
    "parables",
    "third_narrative_section");

declare function tei2json:main()
as xs:string {
    tei2json:create-json-collection-if-not-available(),
    "works"
};

declare function tei2json:create-json-collection-if-not-available()
as xs:string? {
    if (xmldb:collection-available($tei2json:json)) then
        ()
    else
        xmldb:create-collection($tei2json:textgrid, "json")
};

declare function tei2json:get-transcriptions-and-transliterations()
as element(tei:text)+ {
    collection($tei2json:data)//tei:text[@type = ("transcription", "transliteration")][tei2json:has-text-milestone(.)]
};

declare function tei2json:has-text-milestone($text as element(tei:text))
as xs:boolean {
    exists($text//tei:milestone[@unit = $tei2json:milestone-types])
};