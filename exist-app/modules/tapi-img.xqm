xquery version "3.1";

(: 
 : 
 :)

module namespace tapi-img="http://ahikar.sub.uni-goettingen.de/ns/tapi/images";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace functx="http://www.functx.com";

declare function tapi-img:has-manifest-tile($manifest-uri as xs:string)
as xs:boolean {
    let $manifest-doc := commons:get-aggregation($manifest-uri)
    let $aggregated := $manifest-doc//ore:aggregates
    let $is-tile :=
        for $element in $aggregated return
            let $stripped-uri := substring-after($element/@rdf:resource/string(), "textgrid:")
            return
                tapi-img:is-resource-tile($stripped-uri)
    return
        if (functx:is-value-in-sequence(true(), $is-tile)) then
            true()
        else
            false()
};

declare function tapi-img:is-resource-tile($uri)
as xs:boolean {
    let $metadata := commons:get-metadata-file($uri)
    return
        $metadata//tgmd:format = "text/linkeditorlinkedfile"
};