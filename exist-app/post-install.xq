xquery version "3.1";

import module namespace functx="http://www.functx.com";

(: the target collection into which the app is deployed :)
declare variable $target external;
declare variable $ahikar-base := "/db/apps/ahikar";
declare variable $tg-base := "/db/apps/sade/textgrid";

declare function local:move-and-rename($filename as xs:string) as item()* {
    let $data-file-path := $ahikar-base || "/data/"
    let $target-data-collection := $tg-base || "/data/"
    let $target-meta-collection := $tg-base || "/meta/"
    let $target-agg-collection := $tg-base || "/agg/"
    let $target-tile-collection := $tg-base || "/tile/"
    
    let $file-type := functx:substring-after-last($filename, "_")
        => substring-before(".xml")
    
    return
        
        switch ($file-type)
            case "meta" return
                let $new-filename := substring-before($filename, "_meta") || ".xml"
                return
                    ( 
                        xmldb:move($data-file-path, $target-meta-collection, $filename),
                        xmldb:rename($target-meta-collection, $filename, $new-filename)
                    )
            case "tile" return 
                xmldb:move($data-file-path, $target-tile-collection, $filename)
            case "sample" return
                xmldb:move($data-file-path, $target-data-collection, $filename)
            default return
                xmldb:move($data-file-path, $target-agg-collection, $filename)
};

(:  set admin password on deployment. Convert to string
    so local development will not fail because of missing
    env var. :)

(
    if(environment-variable("EXIST_ADMIN_PW_RIPEMD160"))
    then
        (update replace doc('/db/system/security/exist/accounts/admin.xml')//*:password/text() with text{ string(environment-variable("EXIST_ADMIN_PW_RIPEMD160")) },
         update replace doc('/db/system/security/exist/accounts/admin.xml')//*:digestPassword/text() with text{ string(environment-variable("EXIST_ADMIN_PW_DIGEST")) })
    else (: we do not have the env vars available, so we leave the configuration as it is :) 
        true() 

),

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
(let $path := $ahikar-base || "/modules/tapi.xqm"
return (sm:chown($path, "admin"), sm:chmod($path, "rwsrwxr-x"))),

(: set owner and mode for deployment module :)
(let $path := $ahikar-base || "/modules/deploy.xqm"
return (sm:chown($path, "admin"), sm:chmod($path, "rwsrwxr-x"))),

(: set owner and mode for testtrigger module :)
(let $path := $ahikar-base || "/modules/testtrigger.xqm"
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
        "ahiqar_collection_meta.xml",
        "ahiqar_tile.xml",
        "ahiqar_tile_meta.xml")
        "kant_sample.xml")

    return
        ( 
            for $file in $files return
                local:move-and-rename($file)
        )
),

(: make Ahikar specific OpenAPI config available to the OpenAPI app :)
( 
    if (xmldb:collection-available("/db/apps/openapi")) then
        (xmldb:remove("/db/apps/openapi", "openapi-config.xml"),
        xmldb:move($ahikar-base, "/db/apps/openapi", "openapi-config.xml"))
    else
        ()
)