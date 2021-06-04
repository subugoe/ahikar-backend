xquery version "3.1";

module namespace san="http://ahikar.sub.uni-goettingen.de/ns/annotations/save";

import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "/db/apps/ahikar/modules/AnnotationAPI/annotations.xqm";
import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "/db/apps/ahikar/modules/commons.xqm";
import module namespace edit="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial" at "/db/apps/ahikar/modules/AnnotationAPI/editorial.xqm";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0.1/functx/functx.xq";
import module namespace motifs="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs" at "/db/apps/ahikar/modules/AnnotationAPI/motifs.xqm";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $san:server :=
    if(try {
        requestr:hostname() = "existdb"
    } catch * {
        true()
    })
        then $commons:expath-pkg/*/@name => replace("/$", "")
        else "http://localhost:8094/exist/restxq";

declare
    %rest:GET
    %rest:HEAD
    %rest:path("/annotations/save")
    %rest:query-param("token", "{$token}")
function san:main($token) {
    if( $token ne environment-variable("APP_DEPLOY_TOKEN" )) then
        error(QName("error://1", "deploy"), "Deploy token incorrect.")
    else
        let $sysout := util:log-system-out("Creating and storing the AnnotationCollections and AnnotationPages…")
        let $make-json-dir :=
            if (xmldb:collection-available($commons:json)) then
                ()
            else
                xmldb:create-collection("/db/data/textgrid", "json")
        let $main-collection := map:keys($anno:uris)
        let $languages := map:get($anno:uris, $main-collection) => map:keys()
        for $lang in $languages return
            let $manifests := map:get($anno:uris, $main-collection) => map:get($lang) => map:keys()
            for $manifest in $manifests return
                let $teixml := anno:find-in-map($anno:uris, $manifest)
                
                let $pages-in-manifest := 
                    for $tei in anno:find-in-map($anno:uris, $manifest) return
                        let $doc := commons:open-tei-xml($tei)
                        return
                            $doc//tei:pb[@facs]/@n/string()
                return
                    (for $page in $pages-in-manifest return
                        let $items := 
                            try {
                                local:get-annotations($teixml, $page)
                            } catch * {
                                ""
                            }
                        let $result := map { "items": $items } => serialize(map{"method": "json"})
                        let $resource-name := $manifest || "-" || commons:format-page-number($page) || "-items.json"
                        return
                            xmldb:store-as-binary($commons:json, $resource-name, $result),
                    util:log-system-out("Storing finished. For possible errors in this process see expath-repo.log."))
};

declare function local:get-annotations($teixml-uri as xs:string,
    $page as xs:string)
as item()* {
    let $pages := commons:get-page-fragments($teixml-uri, $page)
    return
        (edit:get-annotations($pages, $teixml-uri),
        motifs:get-motifs($pages, $teixml-uri))
};

declare function san:make-items-for-TEI($uri as xs:string) {
    let $log := util:log-system-out("Recreate annotation items for TEI file " || $uri)
    let $make-json-dir :=
        if (xmldb:collection-available($commons:json)) then
            ()
        else
            xmldb:create-collection("/db/data/textgrid", "json")
    let $teixml-uri := local:extract-uri-from-base-uri($uri)
    let $tei := commons:open-tei-xml($teixml-uri)
    let $manifest-uri := local:determine-manifest($teixml-uri)
    let $pages-in-TEI := $tei//tei:pb/@n/string()
    return
        (for $page in $pages-in-TEI return
            let $items := 
                try {
                    local:get-annotations($teixml-uri, $page)
                } catch * {
                    util:log("INFO", "Annotations couldn't be created for " || $teixml-uri)
                }
            let $result := map { "items": $items } => serialize(map{"method": "json"})
            let $resource-name := $manifest-uri || "-" || commons:format-page-number($page) || "-items.json"
            return
                xmldb:store-as-binary($commons:json, $resource-name, $result),
        util:log-system-out("Storing finished. For possible errors in this process see exist.log."))
};

declare function local:determine-manifest($teixml-uri as xs:string) {
    for $doc in collection($commons:agg) return
        if (matches($doc//ore:aggregates/@rdf:resource, $teixml-uri)) then
            local:extract-uri-from-base-uri(base-uri($doc))
        else
            ()
};

declare function local:extract-uri-from-base-uri($base-uri as xs:string) {
    functx:substring-after-last($base-uri, "/")
    => substring-before(".xml")
};
