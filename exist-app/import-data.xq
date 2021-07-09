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
    for $collection in ($commons:data, $commons:agg, $commons:meta, $commons:tile, $commons:json, $commons:html)
    where xmldb:collection-available($collection)
    let $resources := xmldb:get-child-resources($collection)
    for $resource in $resources
    return
        xmldb:remove($collection, $resource)
};

declare function local:publish() {
    let $uri := "textgrid:3r132"
    let $sid := commons:get-textgrid-session-id()
    let $user := "admin"
    let $password := environment-variable("EXIST_ADMIN_PW")
    return
        connect:publish($uri, $sid, $user, $password, false())
};

(
    local:cleanup(),
    local:publish()
)