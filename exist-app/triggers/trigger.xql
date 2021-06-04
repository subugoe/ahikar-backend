xquery version "3.1";

module namespace trigger="http://exist-db.org/xquery/trigger";

import module namespace san="http://ahikar.sub.uni-goettingen.de/ns/annotations/save" at "/db/apps/ahikar/modules/AnnotationAPI/save-annotations.xqm";

declare function trigger:after-create-document($uri as xs:anyURI) {
    if (ends-with($uri, ".xml")) then
        san:make-items-for-TEI($uri)
    else
        ()
};

declare function trigger:after-update-document($uri as xs:anyURI) {
    if (ends-with($uri, ".xml")) then
        san:make-items-for-TEI($uri)
    else
        ()
};
