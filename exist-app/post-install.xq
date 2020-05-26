xquery version "3.1";
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:move-and-rename($filename as xs:string) {
    let $data-file-path := "/db/apps/ahikar/data/"
    let $target-data-collection := "/db/apps/sade/textgrid/data/"
    let $target-meta-collection := "/db/apps/sade/textgrid/meta/"
    let $target-agg-collection := "/db/apps/sade/textgrid/agg/"
    return
        if(matches($filename, "meta")) then
            let $new-filename := substring-before($filename, "_meta") || ".xml"
            return
                (
                    xmldb:move($data-file-path, $target-meta-collection, $filename),
                    xmldb:rename($target-meta-collection, $filename, $new-filename)
                )
        else
            if (matches($filename, "sample")) then
                xmldb:move($data-file-path, $target-data-collection, $filename)
            else
                xmldb:move($data-file-path, $target-agg-collection, $filename)
};


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

(: move the sample XMLs to sade/textgrid to be available in the viewer :)
(
    let $files :=
        (
        "ahiqar_sample.xml",
        "ahiqar_sample_meta.xml",
        "ahiqar_agg.xml",
        "ahiqar_agg_meta.xml",
        "ahiqar_images.xml",
        "ahiqar_images_meta.xml",
        "ahiqar_collection.xml",
        "ahiqar_collection_meta.xml")
    return
        (
            for $file in $files return
                local:move-and-rename($file)
        )
)
