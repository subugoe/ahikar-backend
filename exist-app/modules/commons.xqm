xquery version "3.1";

module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace me="http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion" at "/db/apps/ahikar/modules/motifs-expansion.xqm";
import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "tokenize.xqm";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0.1/functx/functx.xq";

declare variable $commons:expath-pkg := doc("../expath-pkg.xml");
declare variable $commons:version := $commons:expath-pkg/*/@version;
declare variable $commons:tg-collection := "/db/data/textgrid";
declare variable $commons:data := $commons:tg-collection || "/data/";
declare variable $commons:meta := $commons:tg-collection || "/meta/";
declare variable $commons:agg := $commons:tg-collection || "/agg/";
declare variable $commons:tile := $commons:tg-collection || "/tile/";
declare variable $commons:json := $commons:tg-collection || "/json/";
declare variable $commons:html := $commons:tg-collection || "/html/";
declare variable $commons:tmp := xmldb:create-collection($commons:tg-collection, "tmp") || "/";
declare variable $commons:appHome := "/db/apps/ahikar";

declare variable $commons:ns := "http://ahikar.sub.uni-goettingen.de/ns/commons";
declare variable $commons:anno-ns := "http://ahikar.sub.uni-goettingen.de/ns/annotations";

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

(:~
 : Return the parent aggregation of a given URI.
 : 
 : @param $uri The resource's URI
 : @return The URI of the given resource's parent aggregation
 :)
declare function commons:get-parent-aggregation($uri as xs:string)
as xs:string? {
    if (collection($commons:agg)[.//@rdf:resource = "textgrid:" || $uri]) then
        collection($commons:agg)[.//@rdf:resource = "textgrid:" || $uri]
        => base-uri()
        => substring-after("agg/")
        => substring-before(".xml")
    else
        ()
};

declare function commons:get-page-fragments($teixml-uri as xs:string,
    $page as xs:string)
as element()+ {
    let $nodeURI := commons:get-document($teixml-uri, "data")/base-uri()
    let $text-types := commons:get-text-types($teixml-uri)
    for $type in $text-types return
        commons:get-page-fragment($nodeURI, $page, $type)
};

declare function commons:get-text-types($teixml-uri as xs:string)
as xs:string+ {
    let $langs := commons:get-languages($teixml-uri)
    return
        if ($langs = "karshuni") then
            ("transcription", "transliteration")
        else
            "transcription"
};

declare function commons:get-languages($teixml-uri as xs:string)
as xs:string+ {
    let $xml-doc := commons:open-tei-xml($teixml-uri)
    return
        $xml-doc//tei:text[@xml:lang[. = ("syc", "ara", "karshuni")]]/@xml:lang/string()
};

(:~
 : Returns a given page from a requested TEI document and from the requested text type.
 : In some cases the requested text type isn't available or doesn't have any text, so that
 : no page fragment can be retrieved.
 :
 : @param $tei-xml-base-uri The base URI of the requested TEI document
 : @param $page The page as given in tei:pb/@n
 : @param $text-type Either "transcription" or "transliteration"
 : @return The requested page in the resp. text type if available
 :)
declare function commons:get-page-fragment($tei-xml-base-uri as xs:string,
    $page as xs:string,
    $text-type as xs:string)
as element() {
    if (local:has-text-content($tei-xml-base-uri, $page, $text-type)) then
        let $uri := commons:get-uri-from-anything($tei-xml-base-uri)
        let $node-in-cache := doc-available($commons:tmp || $uri || ".me.xml")
        let $node := 
            if($node-in-cache) then
                doc($commons:tmp || $uri || ".me.xml")/*
            else
                let $result := 
                    doc($tei-xml-base-uri)/tei:TEI
                    => me:main()
                    => commons:add-IDs()
                    => tokenize:main()
                let $store := xmldb:store($commons:tmp, $uri || ".me.xml", $result)
                return
                    $result
        let $start-node-dry-run := $node//tei:text[@type = $text-type]//tei:pb[@n = $page],
            $start-node := 
            (:
                todo remove when motif expansion is aware of this.
                $start-node must contain a single node!
            :)
                if (count($start-node-dry-run) gt 1) then
                    $start-node-dry-run[1]
                else $start-node-dry-run,
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
    else
        ()
};

declare function local:has-text-content($tei-xml-base-uri as xs:string,
    $page as xs:string,
    $text-type as xs:string)
as xs:boolean {
    exists(doc($tei-xml-base-uri)/tei:TEI//tei:text[@type = $text-type]/descendant::tei:pb[@n = $page])
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
        
        (: motifs are encoded as tei:span and get their IDs during the motif
        expansion process if they span more than one line. Therefore some tei:spans
        already have an ID while others don't. :)    
        case element(tei:span) return
            element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
                if ($node/@id) then
                    ()
                else
                    attribute id {generate-id($node)},
                $node/@*,
                commons:add-IDs($node/node())
            }
            
        default return
            element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
                attribute id {generate-id($node)},
                $node/@*,
                commons:add-IDs($node/node())
            }
};

declare function commons:get-end-node($start-node as element(tei:pb))
as element() {
    let $following-pb := $start-node/following::tei:pb[1]
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

declare function commons:compress-to-zip($collection-uri as xs:string)
as xs:string* {
    if (commons:does-zip-need-update()) then
        let $valid-uris := 
            for $uri in xmldb:get-child-resources($collection-uri) return
                if (starts-with($uri, "syc")
                or starts-with($uri, "ara")) then
                    xs:anyURI($collection-uri || $uri)
                else
                    ()
        let $zip := compression:zip($valid-uris, false())
        return
            ( 
                commons:make-last-zip-created(),
                xmldb:store-as-binary("/db/data", "ahikar-json.zip", $zip)
            )
    else
        ()
};

declare function commons:does-zip-need-update()
as xs:boolean {
    let $last-zip-created := commons:get-last-zip-created()
    let $latest-last-modified := commons:get-latest-lastModified()
            
    return
        if (not(exists($last-zip-created))
        or ($last-zip-created lt $latest-last-modified)) then
            true()
        else
            false()
};

declare function commons:make-last-zip-created() {
    let $contents :=
        <last-created>
            {current-dateTime()}
        </last-created>
    return
        xmldb:store("/db/data", "last-zip-created.xml", $contents)
};

declare function commons:get-last-zip-created()
as xs:dateTime? {
    xs:dateTime(doc("/db/data/last-zip-created.xml")/last-created)
};

declare function commons:get-latest-lastModified()
as xs:dateTime {
    let $last-modifieds := collection($commons:meta)//tgmd:lastModified
    let $sorted-modifieds :=
        for $date in $last-modifieds
        order by $date descending
        return
            $date
    return
        $sorted-modifieds[1]
};

declare function commons:make-id-from-idno($TEI as element(tei:TEI))
as xs:string {
    let $idno := $TEI//tei:sourceDesc//tei:msIdentifier/tei:idno
    let $normalized :=
        replace($idno, "\.", "")
        => replace("[\(\)=\[\]\\]", " ")
        => normalize-space()
        => replace(" ", "_")
    return
        (: in some cases the idno doesn't start with a letter but a digit.
        to get a uniform ID we prepend a prefix for all tokens. :)
        "t_" || $normalized
};

(:~
 : Returns all page break numbers for a given TEI resource.
 : 
 : @param $documentURI The TEI resource's URI
 : @return A sequence of all page breaks occuring in the resource
 :)
declare function commons:get-pages-in-TEI($uri as xs:string)
as xs:string+ {
    commons:get-document($uri, "data")//tei:pb[@facs]/@n/string()
};

declare function commons:get-pages-for-text-type($uri as xs:string, 
    $type as xs:string) {
    commons:get-document($uri, "data")//tei:text[@type = $type]//tei:pb/@n/string()
};

declare function commons:format-page-number($pb as xs:string) {
    replace($pb, " ", "")
    => replace("[^a-zA-Z0-9]", "")
};

declare function commons:extract-uri-from-base-uri($base-uri as xs:string) {
    functx:substring-after-last($base-uri, "/")
    => substring-before(".xml")
};

(:~ Gets the URI from base-uri() and any textgrid uri 
 : $anyUriForm – accepts base-uri(), textgrid URI and URI (= textgrid
 : base URI without prefix)
 : @return URI :)
declare function commons:get-uri-from-anything($anyUriForm as xs:string) {
    if(contains($anyUriForm, "/") and ends-with($anyUriForm, ".xml")) then
        $anyUriForm => commons:extract-uri-from-base-uri()
    else if (starts-with($anyUriForm, "textgrid:") and contains($anyUriForm, ".")) then
        $anyUriForm => substring-after(":") => substring-before(".")
    else if (starts-with($anyUriForm, "textgrid:")) then
        $anyUriForm => substring-after(":")
    else
        $anyUriForm
};

(:~
 : Gets the parent URI of a resource.
 : Note: in textgrid a URI can be present in multiple aggregations. Currently
 : this feature is not used for ahikar.
 : @param $uri – URI (textgrid base URI without prefix)
 : @return URI of the parent aggregation :)
declare function commons:get-parent-uri($uri as xs:string)
as xs:string {
    collection($commons:agg)//*[@rdf:resource eq "textgrid:" || $uri]/base-uri()
    => commons:extract-uri-from-base-uri()
};

(:~
 : Prepares a metadata map for a resource/collection
 : @param $uri – URI (textgrid base URI without prefix) 
 : @return A map with keys: title, textgrid-uri, uri, format :)
declare function commons:get-resource-information($uri as xs:string) {
    let $metadata := doc($commons:meta || $uri || ".xml")
    return
        map{
            "title": string($metadata/tgmd:title),
            "textgrid-uri": string($metadata/tgmd:textgridUri),
            "uri": commons:get-uri-from-anything(string($metadata/tgmd:textgridUri)),
            "format": string($metadata/tgmd:format),
            "parent": commons:get-parent-uri($uri)
        }
};

declare function commons:get-parent-collection-information($uri as xs:string)
as map(*){
    commons:get-parent-uri($uri)
    => commons:get-resource-information()
};
