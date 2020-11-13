xquery version "3.1";

module namespace tc="http://ahikar.sub.uni-goettingen.de/ns/tests/commons";

declare namespace http = "http://expath.org/ns/http-client";

declare variable $tc:server := "http://0.0.0.0:8080/exist/restxq";

declare function tc:is-endpoint-http200($url as xs:string) as xs:boolean {
    let $http-status := tc:get-http-status($url)
    return
        $http-status = "200"
};

declare function tc:get-http-status($url as xs:string) as xs:string {
    let $req := tc:make-request($url)
    return
        http:send-request($req)[1]/@status
};

declare function tc:make-request($url as xs:string)
as element() {
    <http:request href="{$url}" method="get">
        <http:header name="Connection" value="close"/>
   </http:request>
};