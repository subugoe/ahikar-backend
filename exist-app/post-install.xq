xquery version "3.1";

import module namespace functx="http://www.functx.com";

declare namespace conf = "http://exist-db.org/Configuration";

(: the target collection into which the app is deployed :)
declare variable $target external; (: := "/db/apps/ahikar"; :)
declare variable $appsTarget := '/' || tokenize($target, '/')[position() lt last()] => string-join('/');
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

(:~
 : get absolute path to all resources (xml and binary) in a collection, recursively.
 : @param $target path to a collection as xs:string
 : @return sequence of all resources as xs:string
 :)
declare function local:get-child-resources-recursive($target as xs:string)
as xs:string* {
    xmldb:get-child-resources($target) ! ($target || "/" || .),
    xmldb:get-child-collections($target) ! local:get-child-resources-recursive($target || "/" || .) 
};

declare function local:prepare-index($targetCollection as xs:string, $indexFile as xs:string) {
        if (xmldb:collection-available($targetCollection)) then
        (
            let $contents := doc($target || "/" || $indexFile)/*
            let $store := xmldb:store($targetCollection, "collection.xconf", $contents)
            return
                xmldb:remove($target, $indexFile)
        )
    else
        (
            xmldb:create-collection("/db/system/config/db/", substring-after($targetCollection, "/db/system/config/db/")),
            let $contents := doc($target || "/" || $indexFile)/*
            let $store := xmldb:store($targetCollection, "collection.xconf", $contents)
            return
                xmldb:remove($target, $indexFile)
        )
};

(:  set admin password on deployment. Convert to string
    so local development will not fail because of missing
    env var. :)

(
    let $adminDoc := doc('/db/system/security/exist/accounts/admin.xml')
    return
        if(environment-variable("EXIST_ADMIN_PW_RIPEMD160"))
        then
            (update replace $adminDoc//conf:password/text() with text{ replace(environment-variable("EXIST_ADMIN_PW_RIPEMD160"), '"', '') },
            if($adminDoc//conf:digestPassword) then
                update replace $adminDoc//conf:digestPassword/text() with text{ string(environment-variable("EXIST_ADMIN_PW_DIGEST")) }
            else
                let $element := 
                    element conf:digestPassword { 
                        text { string(environment-variable("EXIST_ADMIN_PW_DIGEST")) }
                    }
                return
                    update insert $element into $adminDoc/conf:account
            )
        else (: we do not have the env vars available, so we leave the configuration as it is :) 
            true()
),

( 
    (: register REST APIs :)
    for $uri in local:get-child-resources-recursive($target)[ends-with(., ".xqm")]
        let $content := $uri => util:binary-doc() => util:base64-decode()
        where contains($content, "%rest:")
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

(: create trigger and index config.
 : simply moving the file from one place to the other doesn't cause eXist-db to recognize the
 : config. neither does reindexing after moving the file.
 : therefore we have to create a new file and copy the contents of /db/apps/ahikar/collection-*.xconf. :)
(
    local:prepare-index("/db/system/config/db/data/textgrid/data", "collection-data.xconf"),
    local:prepare-index("/db/system/config/db/data/textgrid/agg", "collection-agg.xconf")
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
    if (xmldb:collection-available($appsTarget || "/openapi")) then
        (xmldb:remove($appsTarget || "/openapi", "openapi-config.xml"),
        xmldb:move($target, $appsTarget || "/openapi", "openapi-config.xml"))
    else
        ()
)
