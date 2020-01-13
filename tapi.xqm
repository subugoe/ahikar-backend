xquery version "3.1";

(:~
 : This module provides the TextAPI for Ahikar.
 :
 : @author Mathias Göbel
 : @version 0.0.0
 : @since 0.0.0
 : :)

module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi";

declare namespace expkg="http://expath.org/ns/pkg";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace rest="http://exquery.org/ns/restxq";
import module namespace config="https://sade.textgrid.de/ns/config" at "modules/config.xqm";

declare variable $tapi:responseHeader200 :=
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>;

declare
    %rest:GET
    %rest:path("/api/info")
    %output:method("json")
function tapi:info-rest()
as item()+ {
    $tapi:responseHeader200,
    tapi:info()
};

declare function tapi:info()
as map(*) {
    map {
        "version": string($config:expath-descriptor/@version)
    }
};
