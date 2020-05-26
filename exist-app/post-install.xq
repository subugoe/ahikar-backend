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
    let $data-file-path := "/db/apps/ahikar/data/"
    let $target-data-collection := "/db/apps/sade/textgrid/data/"
    let $target-meta-collection := "/db/apps/sade/textgrid/meta/"
    let $target-agg-collection := "/db/apps/sade/textgrid/agg/"
    return
        (
            xmldb:move($data-file-path, $target-data-collection, "ahiqar_sample.xml"),
            xmldb:move($data-file-path, $target-agg-collection, "ahiqar_agg.xml"),
            xmldb:move($data-file-path, $target-agg-collection, "ahiqar_collection.xml"),
            xmldb:move($data-file-path, $target-agg-collection, "ahiqar_images.xml"),
            xmldb:move($data-file-path, $target-meta-collection, "ahiqar_agg_meta.xml"),
            xmldb:move($data-file-path, $target-meta-collection, "ahiqar_sample_meta.xml"),
            xmldb:move($data-file-path, $target-meta-collection, "ahiqar_collection_meta.xml"),
            xmldb:move($data-file-path, $target-meta-collection, "ahiqar_images_meta.xml")
        )
)
