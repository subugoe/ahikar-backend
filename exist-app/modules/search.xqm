xquery version "3.1";

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
as map(*) {
let $body := util:base64-decode($body) => parse-json()
let $searchExpression := $body('query')('simple_query_string')('query')
(: validate query string :)
let $kwicSize := $body('kwicsize')
let $returnSize := $body('size')
let $returnStart := $body('from')

let $collectionWithIndexes := '/db/data/textgrid/data'
let $options :=
        <options>
            <default-operator>yes</default-operator>
            <phrase-slop>3</phrase-slop>
            <leading-wildcard>yes</leading-wildcard>
            <filter-rewrite>no</filter-rewrite>
        </options>

let $hits :=
    try {
        for $hit at $pos in collection($collectionWithIndexes)//tei:ab[ft:query(., $searchExpression, $options)]
        let $baseUri := $hit/base-uri()
        
        let $textgridUri := tokenize($baseUri, "/")[last()] => substring-before('.xml')
        let $edition := commons:get-parent-aggregation($textgridUri)
        let $collection := commons:get-parent-aggregation($edition)

        let $label as xs:string := tapi-mani:get-manifest-title($textgridUri)
        let $n as xs:string := string($hit/preceding::tei:pb[1]/@n)
    
        let $score as xs:float := ft:score($hit)
    (:    let $kwic := kwic:summarize($hit, <config width="{$kwicSize}"/>)//span :)
        
        order by $score descending
        return
            map{
    (:        "_id": $baseUri,:)
    (:        "_index": tokenize($baseUri, "/")[last() -1],:)
    (:        "title": string($hit/root()//tei:title),:)

            "label": $label,
            "n": $n,
            "item": '/api/textapi/ahikar/' || $collection || '/' || $edition || '-' || $n || '/latest/item.json' (: = id w/o base-url :)
    
    (:        "parent": $textgridAggregation, :)
    (:        "hit": $hit => util:node-id():)
    (:        "score": $score :)
    (:        "kwic": map{ :)
    (:            "prev": $kwic[1] => string(), :)
    (:            "hit": $kwic[2] => string(), :)
    (:            "following": $kwic[3] => string()} :)
    
        }
    } catch * {
        ()
    }

let $count as xs:integer := count($hits)

let $timing := util:system-dateTime()
let $took := (current-dateTime() - $timing) => seconds-from-duration() * 1000 (: milliseconds :)

return
    map{
        "request": $body,
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