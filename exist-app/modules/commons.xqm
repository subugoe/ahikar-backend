xquery version "3.1";

module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $commons:expath-pkg := doc("../expath-pkg.xml");
declare variable $commons:version := $commons:expath-pkg/*/@version;
declare variable $commons:tg-collection := "/db/apps/sade/textgrid";
declare variable $commons:data := $commons:tg-collection || "/data/";
declare variable $commons:meta := $commons:tg-collection || "/meta/";
declare variable $commons:agg := $commons:tg-collection || "/agg/";
declare variable $commons:appHome := "/db/apps/ahikar";

declare variable $commons:responseHeader200 :=
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>;

declare function commons:get-aggregation($manifest-uri as xs:string)
as document-node() {
    doc($commons:agg || $manifest-uri || ".xml")
};

declare function commons:get-xml-uri($manifest-uri as xs:string)
as xs:string {
    let $aggregation-file := commons:get-aggregation($manifest-uri)
    return
        $aggregation-file//ore:aggregates[1]/@rdf:resource
        => substring-after(":")
};

declare function commons:get-tei-xml-for-manifest($manifest-uri as xs:string)
as document-node() {
    let $xml-uri := commons:get-xml-uri($manifest-uri)
    return
        doc($commons:data || $xml-uri || ".xml")
};

declare function commons:open-tei-xml($tei-xml-uri as xs:string)
as document-node() {
    doc($commons:data || $tei-xml-uri || ".xml")
};