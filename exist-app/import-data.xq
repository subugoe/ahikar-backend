xquery version "3.1";

(:~
 : This script removes existing (sample) data from the data collection and triggers a
 : publish process for the main edition of the Ahiqar project with tg-connect.
 : Can also publish any sub-collection or resource by adjusting $uri at local:publish().
 :)

import module namespace connect="https://sade.textgrid.de/ns/connect" at "/db/apps/textgrid-connect/modules/connect.xqm";
import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "modules/commons.xqm";

(:~
 : Remove all data present. Mainly used to cleanup sample data.
 : To not interfere with the collection trigger we are going to remove all
 : resources and not the collections themself.
 :)
declare function local:cleanup() {
    for $collection in ($commons:data, $commons:agg, $commons:meta, $commons:tile, $commons:json, $commons:html, $commons:tmp)
    where xmldb:collection-available($collection)
    let $resources := xmldb:get-child-resources($collection)
    for $resource in $resources
    return
        xmldb:remove($collection, $resource)
};

declare function local:publish($uri) {
(:    let $uri := "textgrid:3r132":)
    let $sid := commons:get-textgrid-session-id()
    let $user := "admin"
    let $password := environment-variable("EXIST_ADMIN_PW")
    return
        connect:publish($uri, $sid, $user, $password, false())
};

declare function local:log($message as xs:string) {
    util:log-system-out( util:system-time() || " ::: " || $message )
};

(: followig lists can be copied form tglab navigator context menu :)
let $syriac := (
"textgrid:3r678
textgrid:3r145
textgrid:3r679
textgrid:3r67b
textgrid:3r67c
textgrid:3r67d
textgrid:3r67f
textgrid:3r67g
textgrid:3r67h
textgrid:3r67j
textgrid:3r84d
textgrid:3r86p
textgrid:3r9dx
textgrid:3rck1
textgrid:3rcnx
textgrid:3vqkf
textgrid:3vqkh"
) => tokenize("\n")

let $karshuni := (
"textgrid:3r176
textgrid:3r17b
textgrid:3r17c
textgrid:3r17d
textgrid:3r7nv
textgrid:3r17g
textgrid:3r17h
textgrid:3r7tt"    
    ) => tokenize("\n")

let $arabic := (
"textgrid:3r177
textgrid:3r178
textgrid:3r7vw
textgrid:3r7p1
textgrid:3r7p9
textgrid:3r7sk
textgrid:3r7tp
textgrid:3r7vd
textgrid:3r179
textgrid:3r7n0
textgrid:3r9vn
textgrid:3r9wf
textgrid:3rb3z
textgrid:3rbm9
textgrid:3rbmc
textgrid:3rx14"
    ) => tokenize("\n")

return
( 
    local:cleanup(),
    local:log("STARTING IMPORT"), 
    for $uri in ( $syriac, $karshuni, $arabic )
(: uncomment and adjust the following line to update a single item :)
(:    where $uri eq "textgrid:3r9dx":)
    let $log := local:log("publishing " || $uri)
    return
        local:publish($uri),
    
    local:log("FINISHED IMPORT")
)