xquery version "3.1";
(:~
 : The TextGrid Client offers interfaces to the main features of TextGrid,
 : when they are available via REST.
 : @author Ubbo Veentjer
 : @author Mathias Göbel
 : @author Stefan Hynek
 : @version 1.1
 : @see https://sade.textgrid.de
 :)

module namespace tgclient="https://sade.textgrid.de/ns/tgclient";

declare namespace auth="http://textgrid.info/namespaces/middleware/tgauth";
declare namespace env="http://schemas.xmlsoap.org/soap/envelope/";
declare namespace http="http://expath.org/ns/http-client";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace sparql-results="http://www.w3.org/2005/sparql-results#";
declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

(:
 : Queries TextGrid RDF store. Mainly used to get URIs within a collection
 : @param $query - the SPARQL query as string
 : @param $tg-sesame-uri - URL of the public SPARQL endpoint
 : @return the result of the SPARQL query as XML node
:)
declare function tgclient:sparql($query as xs:string, $tg-sesame-uri as xs:string) as node()
{
    let $urlEncodedQuery as xs:string := encode-for-uri($query)
    let $reqUrl := string-join(($tg-sesame-uri, "?query=", $urlEncodedQuery))
    let $reqGet :=
      <http:request method="get">
        <http:header
          name = "accept"
          value = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        />
        <http:header
          name = "connection"
          value = "close"
        />
      </http:request>

    return http:send-request($reqGet, $reqUrl)[2]/node()
};

(:~ Get TextGrid Metadata Object :)
declare function tgclient:getMeta($id as xs:string, $tgcrud-url as xs:string, $sid as xs:string?) as node()
{
    let $reqUrl := string-join(($tgcrud-url,"/",$id,"/metadata?sessionId=", $sid),"")
    let $reqGet :=
      <http:request method="get">
        <http:header name="connection" value="close" />
      </http:request>
    let $result :=
        try {
            http:send-request($reqGet, $reqUrl)[2]//tgmd:MetadataContainerType
        }
        catch * { <error>URI:{ $id } { $err:code }: { $err:description }</error> }
    return
        if( count($result) != 1 ) then <error> { $id } </error> else $result
};

(:~ Get TextGrid Data Object :)
declare function tgclient:getData($id as xs:string, $tgcrud-url as xs:string, $sid as xs:string?)
{
    let $reqUrl := string-join(($tgcrud-url,"/",$id,"/data?sessionId=", $sid),"")
    let $reqGet :=
      <http:request method="get">
        <http:header name="Connection" value="close" />
      </http:request>
    let $getBody := http:send-request($reqGet, $reqUrl)[2]

    return
        switch ($getBody/@mimetype)
            case "text/plain" return
                if ($getBody/@encoding = "URLEncoded") then
                    process:execute(('/usr/bin/curl',$reqUrl, "-s"), ())//line => string-join("&#13;")
                else string($getBody)
            default return  document { $getBody/node() }
};

(:~ Returns a list of TextGrid items within a given aggregation, but only the
    latest revision of an object.
 : @param tguri – the URI of any tg.aggregation
 : @param rdfstore – url to the triple store
 : @return sequence of strings (textgrid URIs) or empty sequence
 :)
declare
  %test:name("sqarql query")
  %test:args("textgrid:vv6f.0", "https://textgridlab.org/1.0/triplestore/textgrid-public")
  %test:assertExists
  %test:assertEquals("textgrid:vv6f.0", "textgrid:vv6g.0", "textgrid:vvc3.0")
  %test:assertXPath("count($result) eq 3")
function tgclient:getAggregatedUris($tguri as xs:string, $rdfstore as xs:string)
as xs:string* {
    let $query := concat("PREFIX ore:<http://www.openarchives.org/ore/terms/> PREFIX tg:<http://textgrid.info/relation-ns#> SELECT ?s WHERE { <",$tguri,"> (ore:aggregates/tg:isBaseUriOf|ore:aggregates)* ?s. FILTER not exists { ?s tg:isDeleted true } . }")
    let $uris := tgclient:sparql($query, $rdfstore)
(:  let $uris := $uris//sparql-results:uri/string() :)
    for $uri in distinct-values( $uris//sparql-results:uri/substring-before(.,'.'))
    where $uri != ''
    let $maxRev := ($uris//sparql-results:uri[starts-with(., $uri)][contains(. , '.')]/number(substring-after(., '.'))) => max()
    return $uri || '.' || $maxRev
};

(: removes the prefix of any given string :)
declare function tgclient:remove-prefix($tguri as xs:string) as xs:string {
    if (contains($tguri, ":")) then
        tokenize($tguri, ":")[position() gt 1] => string-join()
    else
        $tguri
};

(:~
 : Store any arbitrary data to TextGrid
 : @see http://textgridlab.org/doc/services/submodules/tg-crud/docs/index.html#create
 : @result the resulting MetadataContainerType
 :)
declare function tgclient:createData($config as map(*), $title, $format, $data) as node() {
let $sessionId := $config("sid")
let $projectId := $config("pid")
let $tgcrudURL := $config("tgcrudURL")

let $url := $tgcrudURL || "/create" || "?sessionId=" || $sessionId || "&amp;projectId=" || $projectId

let $objectMetadata :=    <ns3:tgObjectMetadata
                            xmlns:ns3="http://textgrid.info/namespaces/metadata/core/2010"
                            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                            xsi:schemaLocation="http://textgrid.info/namespaces/metadata/core/2010
                            http://textgridlab.org/schema/textgrid-metadata_2010.xsd">
                                  <ns3:object>
                                     <ns3:generic>
                                        <ns3:provided>
                                           <ns3:title>{ $title }</ns3:title>
                                           <ns3:format>{ $format }</ns3:format>
                                        </ns3:provided>
                                     </ns3:generic>
                                     <ns3:item />
                                  </ns3:object>
      </ns3:tgObjectMetadata>

let $objectData := $data

let $request :=
    <http:request method="POST" href="{$url}" http-version="1.0">
        <http:multipart media-type="multipart/form-data" boundary="xYzBoundaryzYx">

            <http:header name="Content-Disposition" value='form-data; name="tgObjectMetadata";'/>
            <http:header name="Content-Type" value="text/xml"/>
            <http:body media-type="application/xml">{ $objectMetadata }</http:body>

            <http:header name="Content-Disposition" value='form-data; name="tgObjectData";'/>
            <http:header name="Content-Type" value="application/octet-stream"/>
            <http:body media-type="{$format}">{ $objectData }</http:body>

        </http:multipart>
    </http:request>
let $response := http:send-request($request)

return
    if( $response/@status = "200" )
    then $response//tgmd:MetadataContainerType
    else <error> <status>{ $response/@status }</status> <message>{ $response/@message }</message> </error>
};

(:~ A wrapper for getData that will not return Image data :)
declare function tgclient:get($crud as xs:string, $uri as xs:string, $sid as xs:string){
let
    $meta := tgclient:getMeta($uri, $sid, $crud),
    $data :=    if( $meta//tgmd:format/contains(., "tg.aggregation")
                    and not($meta//tgmd:title/contains(., "Images")) )
                then
                    tgclient:getData($uri, $sid, $crud)
                else (),
    $data := if($data//ore:aggregates) then $data else ()

return
   (
       $meta,
        for $uri in $data//ore:aggregates/string(@rdf:resource)
        where contains($uri, "textgrid:")
        return tgclient:get($crud, $uri, $sid)
   )
};

(:~ returns all items and metadata related to an aggregation URI :)
declare function tgclient:tgsearch-navigation-agg($uri as xs:string, $sid as xs:string) as node() {
    let $tgsearch-nonpublic := "https://textgridlab.org/1.0/tgsearch/navigation"
    let $API := "/agg/"
    let $url := $tgsearch-nonpublic || $API || $uri || "?sid=" || $sid
    let $reqGet := <http:request method="get" />

    return
	http:send-request($reqGet, $url)[2]/node()
};

declare function tgclient:tgsearch-query-filter($filters as element(filters), $query as xs:string, $sid as xs:string, $limit as xs:integer, $start as xs:integer) {
let $url := "https://textgridlab.org/1.0/tgsearch/search/?"
let $q := if($query = "") then () else "q="|| $query
let $filter := for $f in $filters//filter
               return
                  "filter="||$f/@key||":"||$f/@value,
    $parameter := string-join(($q, $filter, ("sid="||$sid), ("limit="||$limit), ("start="||$start)), "&amp;")
return
    doc($url|| $parameter )
};

declare function tgclient:confserv(){
let $confservUrl := "https://textgridlab.org/1.0/confserv/getAll"
let $reqGet :=
    <http:request method="get" />
let $confserv :=
    http:send-request($reqGet, $confservUrl)[2]/text()
        => util:base64-decode()
        => parse-json()

return
map:merge(
    for $key at $pos in $conf?*?*?*?("key")
    let $value := $conf?*?*?*?("value")[$pos]
    return
        map:entry($key, $value))
};

declare function local:soapHeader($requestName as xs:string) as node() 
{
  <http:header
    name = "SOAP-Action"
    value = "http://textgrid.info/namespaces/middleware/tgauth/{ $requestName }"
  />
};

declare function local:soapElement($requestName as xs:string, $sid as xs:string, $XML as node()*) {
    <env:Envelope>
        <env:Body>{
            element { QName("http://textgrid.info/namespaces/middleware/tgauth", $requestName||"Request") } {
                <auth>{ $sid }</auth>,
                $XML
            }
        }</env:Body>
    </env:Envelope>
};

declare function local:tgAuth-call($authUrl as xs:string, $soapHeader as node(), $soapElement as node()) as node()* {
  let $reqPost :=
    <http:request method='post'>
      { $soapHeader }
    </http:request>

    return
        http:send-request(
          $reqPost,
          $authUrl,
          $soapElement
        )[1]/env:Body/node()
};

declare function tgclient:tgauth-tgAssignedProjects($sid as xs:string) {
let $authUrl := tgclient:confserv()?("tgauth")
let $soapHeader := local:soapHeader("tgAssignedProjects")
let $soapElement := local:soapElement("tgAssignedProjects", $sid, <auth:level>0</auth:level>)
return
    local:tgAuth-call($authUrl, $soapHeader, $soapElement)
};

(:~
 : Creates an aggregation, either empty or filled with the provided textgrid-URIs
 : @param $config – a map containing static parameters "pid", "sid" and "tgCrudUrl"
 : @param $title – the name of the aggregation
 : @param $uris – a sequence of textgrid URIs
:)
declare function tgclient:createAggregation($config as map(*), $title as xs:string, $uris as xs:string+)
as element(tgmd:MetadataContainerType) {
let $data := (: rdf:Description/@rdf:about will be set by the CRUD :)
    document {
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ore="http://www.openarchives.org/ore/terms/">
        <rdf:Description xmlns:tei="http://www.tei-c.org/ns/1.0">
        {for $uri in $uris
        return <ore:aggregates rdf:resource="{$uri}"/>}
        </rdf:Description>
    </rdf:RDF>}
return
    tgclient:createData($config, $title, "text/tg.aggregation+xml", $data)
};
