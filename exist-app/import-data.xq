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

(: followig lists can be copied form tglab navigator context menu :)
let $syriac := (
"textgrid:3r678.0
textgrid:3r145.0
textgrid:3r679.0
textgrid:3r67b.0
textgrid:3r67c.0
textgrid:3r67d.0
textgrid:3r67f.0
textgrid:3r67g.0
textgrid:3r67h.0
textgrid:3r67j.0
textgrid:3r84d.0
textgrid:3r86p.0
textgrid:3r9dx.0
textgrid:3rck1.0
textgrid:3rcnx.0
textgrid:3vqkf.0
textgrid:3vqkh.0"
) => tokenize("\n")

let $karshuni := (
"textgrid:3r176.0
textgrid:3r17b.0
textgrid:3r17c.0
textgrid:3r17d.0
textgrid:3r7nv.0
textgrid:3r17g.0
textgrid:3r17h.0
textgrid:3r7tt.0"    
    ) => tokenize("\n")

let $arabic := (
"textgrid:3r177.0
textgrid:3r178.0
textgrid:3r7vw.0
textgrid:3r7p1.0
textgrid:3r7p9.0
textgrid:3r7sk.0
textgrid:3r7tp.0
textgrid:3r7vd.0
textgrid:3r179.0
textgrid:3r7n0.0
textgrid:3r9vn.0
textgrid:3r9wf.0
textgrid:3rb3z.0
textgrid:3rbm9.0
textgrid:3rbmc.0
textgrid:3rx14.0"
    ) => tokenize("\n")

return
( 
    local:cleanup(),
    util:log-system-out( util:system-time() || "  ::: STARTING IMPORT"), 
    for $uri in ( $syriac, $karshuni, $arabic )
(:    where $uri eq "textgrid:3r9dx.0":)
    let $log := util:log-system-out(util:system-time() || " ::: publishing " || $uri)
    return
        local:publish($uri),
    
    util:log-system-out( util:system-time() || "  ::: FINISHED IMPORT")
)