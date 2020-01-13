xquery version "3.1";

import module namespace config="https://sade.textgrid.de/ns/config" at "../config.xqm";

declare namespace tg="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace digili="http://textgrid.info/namespaces/digilib";

let $id := request:get-parameter("id", "")
return
    if( $id = "" )
    then error( QName("", "DIGILI01"), "Got no ID." )
    else
let $reqUrl := config:get("textgrid.digilib") || $id || "/full/" || config:get("textgrid.digilib.defaultSize") ||"/0/default.jpg"
let $reqGet :=
      <http:request method="get">
        <http:header name="Connection" value="close" />
      </http:request>
let $result := http:send-request($reqGet, $reqUrl)
let $mime := xs:string($result[1][@name="Content-Type"]/@value)
let $last-modified := xs:string($result[1][@name="Last-Modified"]/@value)
let $cache-control := xs:string($result[1][@name="Cache-Control"]/@value)

return
    response:stream-binary(xs:base64Binary($result[2]), $mime)
