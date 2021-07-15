xquery version "3.1";
(:~
 : This is the module preparing the SearchAPI as described
 : at https://subugoe.pages.gwdg.de/ahiqar/api-documentation/
 : @version 0.1.0
 : @since 6.3.0
 :)

module namespace search="http://ahikar.sub.uni-goettingen.de/ns/search";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace rest="http://exquery.org/ns/restxq";
import module namespace tapi-mani="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest" at "tapi-manifest.xqm";


declare
    %rest:HEAD
    %rest:POST("{$body}")
    %rest:path("/search")
    %output:method("json")
    %rest:consumes("application/json")
    %rest:produces("application/json")
function search:main($body)
as item()+ {
    ($commons:responseHeader200,
    search:perform(util:base64-decode($body) => parse-json())
)};

declare function local:validate-query($query as xs:string)
as xs:boolean {
    if(string-length($query) eq 0) then
        error(QName("search", "empty-query"), "got empty query string")
    else if(contains($query, "script")) then
        error(QName("search", "script"), "query contains not allowed string: script")
    else
        true()
};

declare %private function local:get-language-collection-by-uri($teiUri as xs:string)
as xs:string? {
    let $langAggregation := commons:get-parent-uri($teiUri) => commons:get-parent-uri() => commons:get-resource-information()
    return
        switch($langAggregation("title"))
        case "arabic" return "arabic-karshuni"
        case "karshuni" return "arabic-karshuni"
        case "syriac" return "syriac"
        default return ""
};

declare function search:perform($parsed-json as map(*))
as map(*) {
    let $startTiming := util:system-dateTime()
    let $body := $json
    let $searchExpression := $body("query")("simple_query_string")("query")
    let $validateQuery := local:validate-query($searchExpression)
    let $returnSize := $body("size")
    let $returnStart := $body("from")
    let $options :=
        <options>
            <default-operator>and</default-operator>
            <phrase-slop>3</phrase-slop>
            <leading-wildcard>yes</leading-wildcard>
            <filter-rewrite>no</filter-rewrite>
        </options>

    let $hits :=
        try {
        for $hit in collection($commons:data)//tei:body[ft:query(., $searchExpression, $options)]
            let $score := ft:score($hit)
            
            let $baseUri := $hit/base-uri()
            let $textgridUri := commons:extract-uri-from-base-uri($baseUri)
            let $edition := commons:get-parent-aggregation($textgridUri)
            let $collection := local:get-language-collection-by-uri($textgridUri)
            let $label := tapi-mani:get-manifest-title($textgridUri)
            let $matches := util:expand($hit)//exist:match
            let $pages := ($matches ! ./preceding::tei:pb[1]/string(@n)) => distinct-values()
            let $type := string($hit/parent::tei:text/@type)
            let $language := string($hit/parent::tei:text/@xml:lang)
            for $page in $pages
            order by $score descending
            return
                map{
                    "type": $type,
                    "lang": $language,
                    "uri-tei": $baseUri,
                    "label": $label,
                    "n": $page,
                    "item": "/api/textapi/ahikar/" || $collection || "/" || $edition || "-" || $page || "/latest/item.json", (: = textapi: "id" w/o base-url :)
                    "match": array{ $matches[./preceding::tei:pb[1]/string(@n) eq $page] ! string(.)}
                }
    } catch * {
        ()
    }

let $count := count($hits)

let $timing := util:system-dateTime()
let $took := ($timing - $startTiming) => seconds-from-duration() (: milliseconds :)

return
    map{
        "request": serialize($body, map{"method": "json"}),
        "took": $took,
        "hits": map{
            "total": map{
                "value": $count
            },
            "hits": array{
                $hits
                    [position() le $returnStart + $returnSize]
                    [position() gt $returnStart]
            }
        }
    }
};