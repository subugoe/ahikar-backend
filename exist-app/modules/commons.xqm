xquery version "3.1";

module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "tokenize.xqm";

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
    let $node := doc($tei-xml-base-uri)/tei:TEI
        => commons:add-IDs()
        => tokenize:main(),
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

(:~
 : Gets a currently valid or renewed session id from TextGrid
 : @return Session Id
:)
declare function commons:get-textgrid-session-id()
as xs:string {
    (: check if we have a session id :)
    if( util:binary-doc-available("/db/sid.txt") ) then
        (: check if we have to renew the session id :)
        if( current-dateTime() - xs:dayTimeDuration("PT23H55M") lt xmldb:last-modified("/db", "sid.txt")) then
            util:binary-doc("/db/sid.txt") => util:binary-to-string()
        else
            local:create-textgrid-session-id()
    else
        local:create-textgrid-session-id()

};

(:~
 : Gets a new session id from TextGrids WebAuth service and stores it to
 : binary /db/sid.txt
 : @return Session id
:)
declare %private function local:create-textgrid-session-id() {
    let $webauthUrl := "https://textgridlab.org/1.0/WebAuthN/TextGrid-WebAuth.php"
    let $authZinstance := "textgrid-esx2.gwdg.de"
    (: check if env var is present and contains the required delimiter :)
    let $envVarTest :=
        if(not(contains(environment-variable("TGLOGIN"), ":"))) then
            error(QName("auth", "error"), "missing env var TGLOGIN")
        else ()

    let $user :=        environment-variable("TGLOGIN") => substring-before(":")
    let $password :=    environment-variable("TGLOGIN") => substring-after(":")

    let $pw := 
        if(contains($password, '&amp;')) then
            replace($password, '&amp;', '%26')
        else $password
    let $request :=
        <hc:request method="POST" href="{ $webauthUrl }" http-version="1.0">
            <hc:header name="Connection" value="close" />
            <hc:multipart media-type="multipart/form-data" boundary="------------------------{current-dateTime() => util:hash("md5") => substring(0,17)}">
                <hc:header name="Content-Disposition" value='form-data; name="authZinstance"'/>
                <hc:body media-type="text/plain">{$authZinstance}</hc:body>
                <hc:header name="Content-Disposition" value='form-data; name="loginname"'/>
                <hc:body media-type="text/plain">{$user}</hc:body>
                <hc:header name="Content-Disposition" value='form-data; name="password"'/>
                <hc:body media-type="text/plain">{$pw}</hc:body>
            </hc:multipart>
        </hc:request>
    let $response := hc:send-request($request)

    let $sid :=
        string($response[2]//*:meta[@name="rbac_sessionid"]/@content)
    
    let $sidTest :=
        if($sid = "") then
            error(QName("auth", "error"), $response[2])
        else ()

    let $store := xmldb:store-as-binary("/db", "sid.txt", $sid) => sm:chmod("rwxrwx---")

    return
        $sid

};
