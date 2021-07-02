xquery version "3.1";

module namespace dbt="http://ahikar.sub.uni-goettingen.de/ns/database-triggers";

declare namespace trigger="http://exist-db.org/xquery/trigger";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "/db/apps/ahikar/modules/commons.xqm";
import module namespace san="http://ahikar.sub.uni-goettingen.de/ns/annotations/save" at "/db/apps/ahikar/modules/AnnotationAPI/save-annotations.xqm";
import module namespace sh="http://ahikar.sub.uni-goettingen.de/ns/tapi/html/save" at "/db/apps/ahikar/modules/save-html.xqm";

declare function trigger:after-create-document($uri as xs:anyURI) {
    dbt:prepare-collections-for-triggers(),
    dbt:process-triggers($uri)
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    dbt:process-triggers($uri)
};

declare function dbt:process-triggers($uri as xs:anyURI) {
    let $teixml-uri := commons:extract-uri-from-base-uri($uri)
    return    
        if (ends-with($uri, ".xml")) then
            let $text-types := commons:get-text-types($teixml-uri)
            let $fragments :=
                map:merge(
                for $type in $text-types return
                    map:entry($type,
                        map:merge(
                        for $page in commons:get-pages-for-text-type($teixml-uri, $type) return
                            map:entry($page, commons:get-page-fragment($uri, $page, $type))
                        )
                    )
                )
            return
                (san:make-items-for-TEI($teixml-uri, $fragments),
                sh:save-html($teixml-uri, $fragments))
        else
            ()
};

declare function dbt:prepare-collections-for-triggers() {
    if (xmldb:collection-available($commons:html)) then
        ()
    else
        xmldb:create-collection("/db/data/textgrid", "html"),
    if (xmldb:collection-available($commons:json)) then
        ()
    else
        xmldb:create-collection("/db/data/textgrid", "json")
};
