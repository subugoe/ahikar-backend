xquery version "3.1";

module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize" at "tokenize.xqm";

declare variable $commons:expath-pkg := doc("../expath-pkg.xml");
declare variable $commons:version := $commons:expath-pkg/*/@version;
declare variable $commons:tg-collection := "/db/data/textgrid";
declare variable $commons:data := $commons:tg-collection || "/data/";
declare variable $commons:meta := $commons:tg-collection || "/meta/";
declare variable $commons:agg := $commons:tg-collection || "/agg/";
declare variable $commons:tile := $commons:tg-collection || "/tile/";
declare variable $commons:json := $commons:tg-collection || "/json/";
declare variable $commons:appHome := "/db/apps/ahikar";

declare variable $commons:ns := "http://ahikar.sub.uni-goettingen.de/ns/commons";

declare variable $commons:idno-to-sigils-map :=
    map {
        "Borg_ar_201": "Borg. ar. 201",
        "Add_2020": "C",
        "Sachau_162": "S",
        "syr_611": "K",
        "syr_612": "I",
        "syr_434": "B",
        "Add_7200": "L",
        "Brit_Mus_Add_7209": "Brit. Add. 7209",
        "Brit_Libr_Or_9321": "Brit. Or. 9321",
        "Cambrigde_Add_3497": "Cam. Add. 3497",
        "Camb_Add_2886": "Cam. Add. 2886",
        "Cod_Arab_236": "Cod. Arab. 236",
        "Paris_Arabe_3637": "Paris. ar. 3637",
        "Sachau_290_Sachau_339": "Sach. 339",
        "DFM_00614": "DFM 614",
        "GCAA_00486": "GCAA 486",
        "Mingana_syr_133": "Ming. syr. 133",
        "Mingana_ar_christ_93_84": "Ming. ar. 93",
        "Mingana_Syr_258": "Ming. syr. 258",
        "433": "M",
        "Ms_orient_A_2652": "Gotha 2652",
        "430": "D",
        "Or_1292b": "Leiden Or. 1292",
        "Paris_Arabe_3656": "Paris. ar. 3656",
        "syr_422": "N",
        "Sado_no_9": "P",
        "Salhani": "Salhani",
        "Sbath_25": "Sbath 25",
        "Ar_7/229": "A",
        "Manuscrit_4122": "T",
        "Or_2313": "O",
        "Syr_80": "H",
        "162": "J",
        "Sachau_336": "U",
        "Vat_ar_74_Scandar_40": "Vat. ar. 74",
        "Vat_ar_2054": "Vat. ar. 2054",
        "Vat_sir_159": "Vat. syr. 159",
        "Vat_sir_199": "Vat. syr. 199",
        "Vat_sir_424": "Vat. syr. 424"
    };

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

declare function commons:get-transcription-and-transliteration-per-page($teixml-uri as xs:string,
    $page as xs:string)
as element(tei:TEI)+ {
    let $xml-doc := commons:open-tei-xml($teixml-uri)
    let $langs := $xml-doc//tei:text[@xml:lang[. = ("syc", "ara", "karshuni")]]/@xml:lang/string()
    return
        if ($langs = "karshuni") then
            (commons:get-page-fragment-from-uri($teixml-uri, $page, "transcription"),
            commons:get-page-fragment-from-uri($teixml-uri, $page, "transliteration"))
        else
            commons:get-page-fragment-from-uri($teixml-uri, $page, "transcription")
};

(:~
 : Returns a single page from a TEI resource, i.e. all content from the given $page
 : up to the next page break.
 : 
 : @param $documentURI The resource's URI
 : @param $page The page to be returned as tei:pb/@n/string()
 :)
declare function commons:get-page-fragment-from-uri($documentURI as xs:string,
    $page as xs:string,
    $text-type as xs:string)
as element(tei:TEI)? {
    let $nodeURI := commons:get-document($documentURI, "data")/base-uri()
    return
        commons:get-page-fragment($nodeURI, $page, $text-type)
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
        let $node := doc($tei-xml-base-uri)/tei:TEI
            => tokenize:main()
            => commons:add-IDs()
            ,
            $start-node := $node//tei:text[@type = $text-type]//tei:pb[@n = $page],
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

declare function commons:compress-to-zip($collection-uri as xs:string)
as xs:string* {
    if (commons:does-zip-need-update()) then
        let $valid-uris := 
            for $doc in collection($collection-uri) return
                if (contains(base-uri($doc), "sample")) then
                    ()
                else
                    xs:anyURI(base-uri($doc))
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
    return
        replace($idno, "\.", "")
        => replace("[\(\)=\[\]]", " ")
        => normalize-space()
        => replace(" ", "_")
};
