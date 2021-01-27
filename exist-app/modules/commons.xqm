xquery version "3.1";

module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";

declare variable $commons:expath-pkg := doc("../expath-pkg.xml");
declare variable $commons:version := $commons:expath-pkg/*/@version;
declare variable $commons:tg-collection := "/db/data/textgrid";
declare variable $commons:data := $commons:tg-collection || "/data/";
declare variable $commons:meta := $commons:tg-collection || "/meta/";
declare variable $commons:agg := $commons:tg-collection || "/agg/";
declare variable $commons:tile := $commons:tg-collection || "/tile/";
declare variable $commons:appHome := "/db/apps/ahikar";

declare variable $commons:ns := "http://ahikar.sub.uni-goettingen.de/ns/commons";

declare variable $commons:responseHeader200 :=
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>;

declare function commons:get-xml-uri($manifest-uri as xs:string)
as xs:string {
    let $aggregation-file := commons:get-document($manifest-uri, "agg")
    return
        $aggregation-file//ore:aggregates[1]/@rdf:resource
        => substring-after(":")
};

declare function commons:get-tei-xml-for-manifest($manifest-uri as xs:string)
as document-node() {
    let $xml-uri := commons:get-xml-uri($manifest-uri)
    return
        commons:get-document($xml-uri, "data")
};


declare function commons:get-document($uri as xs:string,
    $type as xs:string)
as document-node()? {
    let $collection :=
        switch ($type)
            case "agg" return $commons:agg
            case "data" return $commons:data
            case "meta" return $commons:meta
            default return error(QName($commons:ns, "COMMONS001"), "Unknown type " || $type)
    let $base-uri := $collection || $uri || ".xml"
    return
        if (doc-available($base-uri)) then
            doc($base-uri)
        else
            error(QName($commons:ns, "COMMONS002"), "URI " || $uri || " not found.")
};

declare function commons:get-available-aggregates($aggregation-uri as xs:string)
as xs:string* {
    let $aggregation-doc := commons:get-document($aggregation-uri, "agg")
    for $aggregate in $aggregation-doc//ore:aggregates/@rdf:resource
        let $unprefixed-uri := substring-after($aggregate, "textgrid:")
        let $aggregate-base-uri := $commons:meta || $unprefixed-uri || ".xml"
        return
            if (doc-available($aggregate-base-uri)) then
                $unprefixed-uri
            else
                ()
};

declare function commons:get-page-fragment($tei-xml-base-uri as xs:string,
    $page as xs:string)
as element() {
    let $node := doc($tei-xml-base-uri)/*
        => commons:add-IDs(),
        $start-node := $node//tei:pb[@n = $page and @facs],
        $end-node := commons:get-end-node($start-node),
        $wrap-in-first-common-ancestor-only := false(),
        $include-start-and-end-nodes := true(),
        $empty-ancestor-elements-to-include := ("")
        
    return
        fragment:get-fragment-from-doc(
            $node,
            $start-node,
            $end-node,
            $wrap-in-first-common-ancestor-only,
            $include-start-and-end-nodes,
            $empty-ancestor-elements-to-include)
};

declare function commons:add-IDs($nodes as node()*)
as node()* {
    for $node in $nodes return
        typeswitch ($node)
        
        case text() return
            $node
            
        case comment() return
            ()
            
        case processing-instruction() return
            $node
            
        default return
            element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
                attribute id {generate-id($node)},
                $node/@*,
                commons:add-IDs($node/node())
            }
};

declare function commons:get-end-node($start-node as element(tei:pb))
as element() {
    let $following-pb := $start-node/following::tei:pb[1][@facs]
    return
        if($following-pb) then
            $following-pb
        else
            $start-node/following::tei:ab[last()]
};

declare function commons:get-metadata-file($uri as xs:string)
as document-node() {
    doc($commons:meta || $uri || ".xml")
};

declare function commons:get-aggregation($manifest-uri as xs:string)
as document-node() {
    doc($commons:agg || $manifest-uri || ".xml")
};

declare function commons:open-tei-xml($tei-xml-uri as xs:string)
as document-node() {
    doc($commons:data || $tei-xml-uri || ".xml")
};


