xquery version "3.1";

module namespace san="http://ahikar.sub.uni-goettingen.de/ns/annotations/save";

import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "/db/apps/ahikar/modules/AnnotationAPI/annotations.xqm";
import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "/db/apps/ahikar/modules/commons.xqm";
import module namespace edit="http://ahikar.sub.uni-goettingen.de/ns/annotations/editorial" at "/db/apps/ahikar/modules/AnnotationAPI/editorial.xqm";
import module namespace motifs="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs" at "/db/apps/ahikar/modules/AnnotationAPI/motifs.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare function san:prepare-unit-tests($fragments as map(*))
as item()+ {
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
                            local:get-annotations($teixml, $fragments, $page)
                        } catch * {
                            ""
                        }
                    let $result := map { "items": array{$items} } => serialize(map{"method": "json"})
                    let $resource-name := $manifest || "-" || commons:format-page-number($page) || "-items.json"
                    return
                        xmldb:store-as-binary($commons:json, $resource-name, $result),
                util:log-system-out("Storing finished. For possible errors in this process see expath-repo.log."))
};

declare function local:get-annotations($teixml-uri as xs:string,
    $fragments as map(*),
    $page as xs:string)
as item()* {
    let $pages := local:get-fragments-for-page($fragments, $page)
    return
        (edit:get-annotations($pages, $teixml-uri),
        motifs:get-motifs($pages, $teixml-uri))
};

declare function san:make-items-for-TEI($teixml-uri as xs:string,
    $fragments as map(*)) {
    let $log := util:log-system-out("Recreate annotation items for TEI file " || $teixml-uri)
    let $manifest-uri := local:determine-manifest($teixml-uri)
    let $pages := 
        for $type in map:keys($fragments) return
            map:get($fragments, $type) => map:keys()
    return
        (for $page in $pages return
            let $items := 
                try {
                    local:get-annotations($teixml-uri, $fragments, $page)
                } catch * {
                    util:log("INFO", "Annotations couldn't be created for " || $teixml-uri)
                }
            let $result := map { "items": array{$items} } => serialize(map{"method": "json"})
            let $resource-name := $manifest-uri || "-" || commons:format-page-number($page) || "-items.json"
            return
                xmldb:store-as-binary($commons:json, $resource-name, $result),
        util:log-system-out("Storing finished. For possible errors in this process see exist.log."))
};

declare function local:determine-manifest($teixml-uri as xs:string) {
    for $doc in collection($commons:agg) return
        if (matches($doc//ore:aggregates/@rdf:resource, $teixml-uri)) then
            commons:extract-uri-from-base-uri(base-uri($doc))
        else
            ()
};

declare function local:get-fragments-for-page($fragments as map(*),
    $page as xs:string)
as element(tei:TEI)+ {
    let $text-types := map:keys($fragments)
    for $type in $text-types return
        if (map:get($fragments, $type) => map:keys() = $page) then
            map:get($fragments, $type)
            => map:get($page)
        else
            ()
};
