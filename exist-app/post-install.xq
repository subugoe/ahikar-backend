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
return (sm:chown($path, "admin"), sm:chmod($path, "rwsrwxr-x"))),

(: move the sample XML to sade/textgrid to be available in the viewer :)
(
    let $data-file-path := "/db/apps/ahikar/data/ahiqar_sample.xml"
    let $target-collection := "/db/apps/sade/textgrid/data/"
    return
        xmldb:move($data-file-path, $target-collection)
)
