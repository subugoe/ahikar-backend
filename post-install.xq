xquery version "3.1";
(: the target collection into which the app is deployed :)
declare variable $target external;
(
(: register REST APIs :)
for $uri at $pos in (collection($target)/base-uri())[ends-with(., ".xqm")]
let $content := $uri => util:binary-doc() => util:base64-decode()
let $isRest := if(contains($content, "%rest:")) then true() else false()
where $isRest
return
    exrest:register-module(xs:anyURI($uri))
),

(: set owner and mode for RestXq module :)
(let $path := "/db/apps/ahikar/modules/tapi.xqm"
return (sm:chown($path, "admin"), sm:chmod($path, "rwsrwxr-x")))
