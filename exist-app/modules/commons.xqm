xquery version "3.1";

module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons";

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