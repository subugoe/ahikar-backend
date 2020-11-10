xquery version "3.1";

(: 
 : This module handles the correct selection of an image path for an item.
 :
 : The Ahiqar project has both single- and double-sided images. While the former works
 : without further ado, the latter needs a different URL in order to display to proper
 : image section.
 :)

module namespace tapi-img="http://ahikar.sub.uni-goettingen.de/ns/tapi/images";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";

declare function tapi-img:has-manifest-tile($manifest-uri as xs:string)
as xs:boolean {
    exists(tapi-img:get-tile-uris($manifest-uri))
};

declare function tapi-img:is-resource-tile($uri as xs:string)
as xs:boolean {
    let $metadata := commons:get-metadata-file($uri)
    return
        $metadata//tgmd:format = "text/linkeditorlinkedfile"
};

declare function tapi-img:is-tile-available($uri as xs:string)
as xs:boolean {
    exists(doc($commons:tile || $uri || ".xml"))
};

declare function tapi-img:get-tile-uris($manifest-uri as xs:string)
as xs:string* {
    let $manifest-doc := commons:get-aggregation($manifest-uri)
    let $aggregated := $manifest-doc//ore:aggregates
    for $element in $aggregated return
        let $stripped-uri := substring-after($element/@rdf:resource/string(), "textgrid:")
        return
            if (tapi-img:is-resource-tile($stripped-uri)) then
                $stripped-uri
            else
                ()
};

declare function tapi-img:get-tile($uri as xs:string)
as document-node()? {
    if (tapi-img:is-tile-available($uri)) then
        tapi-img:open-tile($uri)
    else
        ()
};

declare function tapi-img:open-tile($uri as xs:string)
as document-node() {
    doc($commons:tile || $uri || ".xml")
};
