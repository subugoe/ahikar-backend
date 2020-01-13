xquery version "3.1";
(:~
 : Provides the endpoint for SADE Publish process
 :)

import module namespace tgconnect="https://sade.textgrid.de/ns/connect" at "connect.xqm";

let $uri as xs:string := request:get-parameter("uri", ""),
    $sid as xs:string := request:get-parameter("sid", ""),
    $target as xs:string := request:get-parameter("target", "data"),
    $user as xs:string := request:get-parameter("user", ""),
    $password as xs:string := request:get-parameter("password", ""),
    $project as xs:string := request:get-parameter("project", ""),
    $surface as xs:string := request:get-parameter("sf", ""),
    $login as xs:boolean := false()

return
    if( $uri = "" ) then
        error(QName("https://sade.textgrid.de/ns/error", "PUBLISH01"), "no URI provided")
    else
        <div>{
            for $i in tgconnect:publish($uri,$sid,$target,$user,$password,$project,$surface,$login)
            return
                <ok>{ $uri } » { $i }</ok>
        }</div>
