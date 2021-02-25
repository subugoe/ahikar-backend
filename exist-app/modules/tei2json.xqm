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


declare function tei2json:main()
as xs:string {
    "works"
};