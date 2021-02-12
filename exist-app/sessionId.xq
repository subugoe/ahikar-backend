xquery version "3.1";

(:~
 : Provides a sessionId at /db/sid.txt
 : Requires env var TGLOGIN with user:pass, so dba only.
 : 
 : to be scheduled once a day, as session expires.
 : 
 : @author Mathias Göbel
 :   :)

declare namespace html="http://www.w3.org/1999/xhtml";

(:~
 : Gets a TextGrid SessionId
 : 
 : @author Mathias Göbel
 : @param webauth URL, e.g. "https://textgridlab.org/1.0/WebAuthN/TextGrid-WebAuth.php"
 : @param auth instance, e.g. "textgrid-esx2.gwdg.de" for production env
 : @param user DARIAH-DE username (w/o @dariah.eu)
 : @param password corresponding password
 : @return Session Id
 :)
declare function local:getSid(
    $webauthUrl as xs:string,
    $authZinstance as xs:string,
    $user as xs:string,
    $password as xs:string)
as xs:string {
    let $pw := if(contains($password, '&amp;')) then replace($password, '&amp;', '%26') else $password
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
        string($response[2]//html:meta[@name="rbac_sessionid"]/@content)
    return
        if($sid = "")
        then error(QName("auth", "error"), $response[2])
        else $sid
};

let $webauthUrl := "https://textgridlab.org/1.0/WebAuthN/TextGrid-WebAuth.php"
let $authZinstance := "textgrid-esx2.gwdg.de"
let $user :=        environment-variable("TGLOGIN") => substring-before(":")
let $password :=    environment-variable("TGLOGIN") => substring-after(":")

return
    local:getSid($webauthUrl, $authZinstance, $user, $password)
    ! xmldb:store-as-binary("/db", "sid.txt", .)
    => sm:chmod("rwxrwx---")
