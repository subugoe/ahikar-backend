xquery version "3.1";

import module namespace functx="http://www.functx.com";

(: the target collection into which the app is deployed :)
declare variable $target external; (: := "/db/apps/ahikar"; :)
declare variable $tg-base := "/db/data/textgrid";

declare function local:move-and-rename($filename as xs:string) as item()* {
    let $data-file-path := $target || "/data/"
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
            case "teixml" return
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

(: set owner and mode for modules :)
(
    (
        $target || "/modules/tapi.xqm",
        $target || "/modules/deploy.xqm",
        $target || "/modules/testtrigger.xqm",
        $target || "/modules/apitesttrigger.xqm",
        $target || "/modules/prepare-unit-tests.xqm",
        $target || "/modules/AnnotationAPI/save-annotations.xqm"
    ) ! (sm:chown(., "admin"), sm:chmod(., "rwsrwxr-x"))
),

(: move the sample XMLs to /db/data/textgrid to be available in the viewer :)
( 
    
    xmldb:get-child-resources($target || "/data")[ends-with(., ".xml")]
    ! local:move-and-rename(.)
),

(: move CSS to /db/data/resources/css :)
(
    xmldb:create-collection("/db/data/", "resources/css"),
    xmldb:move($target || "/data", "/db/data/resources/css", "ahikar.css")
),

(: move fonts to /db/data/resources/fonts :)
(
    xmldb:move($target || "/resources/fonts", "/db/data/resources/"),
    xmldb:remove($target || "/resources")
),

(: make Ahikar specific OpenAPI config available to the OpenAPI app :)
( 
    if (xmldb:collection-available("/db/apps/openapi")) then
        (xmldb:remove("/db/apps/openapi", "openapi-config.xml"),
        xmldb:move($target, "/db/apps/openapi", "openapi-config.xml"))
    else
        ()
),

(: create trigger config.
 : simply moving the file from one place to the other doesn't cause eXist-db to recognize the
 : config. neither does reindexing after moving the file.
 : therefore we have to create a new file and copy the contents of /db/apps/ahikar/collection.xconf. :)
(
    if (xmldb:collection-available("/db/system/config/db/data/textgrid/data")) then
        (
            let $contents := doc($target || "/collection.xconf")/*
            let $store := xmldb:store("/db/system/config/db/data/textgrid/data", "collection.xconf", $contents)
            return
                xmldb:remove($target, "collection.xconf")
        )
    else
        (
            xmldb:create-collection("/db/system/config/db/", "data/textgrid/data"),
            let $contents := doc($target || "/collection.xconf")/*
            let $store := xmldb:store("/db/system/config/db/data/textgrid/data", "collection.xconf", $contents)
            return
                xmldb:remove($target, "collection.xconf")          
        )
)
