xquery version "3.1";

module namespace tei2json="http://ahikar.sub.uni-goettingen.de/ns/tei2json";

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