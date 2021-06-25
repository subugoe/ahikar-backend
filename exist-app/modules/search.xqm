xquery version "3.1";

module namespace search="http://ahikar.sub.uni-goettingen.de/ns/search";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace rest="http://exquery.org/ns/restxq";

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
let $kwicSize := $body('kwicsize')
let $returnSize := $body('size')
let $returnStart := $body('from')

let $collectionWithIndexes := '/db/data/textgrid/data'
let $options :=
        <options>
            <default-operator>and</default-operator>
            <phrase-slop>3</phrase-slop>
            <leading-wildcard>yes</leading-wildcard>
            <filter-rewrite>no</filter-rewrite>
        </options>

let $hits :=
    for $hit at $pos in collection($collectionWithIndexes)//tei:ab[ft:query(., $searchExpression, $options)]
    let $score as xs:float := ft:score($hit)
    let $baseUri := $hit/base-uri()
    let $kwic := kwic:summarize($hit, <config width="{$kwicSize}"/>)//span
    
    order by $score descending
    return
        map{
        "_id": $baseUri,
        "_index": tokenize($baseUri, "/")[last() -1],
        "title": string($hit/root()//tei:title),
        "hit": $hit => util:node-id(),
        "score": $score,
        "kwic": map{
            "prev": $kwic[1] => string(),
            "hit": $kwic[2] => string(),
            "following": $kwic[3] => string()}
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