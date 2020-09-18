xquery version "3.1";

(: 
 : This module handles calls to the API on collection level, e.g.
 : 
 : /textapi/ahikar/3r9ps/collection.json
 :)

module namespace t-coll="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";

declare variable $t-coll:server := 
    if(requestr:hostname() = "existdb") then
        $commons:expath-pkg/*/@name => replace("/$", "")
    else
        "http://localhost:8094/exist/restxq";

(:~
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @param $collection-uri The unprefixed TextGrid URI of a collection, e.g. '3r132'
 : @return A collection object as JSON
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection-uri}/collection.json")
    %output:method("json")
function t-coll:endpoint($collection-uri as xs:string)
as item()+ {
    $commons:responseHeader200,
    t-coll:get-json($collection-uri, $t-coll:server)
};

(:~
 : Returns information about the main collection for the project. This encompasses
 : the key data described at https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object.
 :
 : This function should only be used for Ahiqar's edition object (textgrid:3r132).
 : It serves as an entry point to the edition and contains all child aggregations with
 : the XMLs and images in them.
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @param $collection-uri The unprefixed TextGrid URI of a collection. For Ahiqar's main collection this is '3r132'.
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable.
 : @return An object element containing all necessary information
 :)
declare function t-coll:get-json($collection-uri as xs:string,
    $server as xs:string)
as item()+ {
    let $metadata-file := t-coll:get-metadata-file($collection-uri)
    let $format-type := t-coll:get-format-type($metadata-file)
    let $sequence := t-coll:make-sequence($collection-uri, $server)
    let $annotationCollection-uri := t-coll:make-annotationCollection-uri($server, $collection-uri)

    return
    <object>
        <textapi>{$commons:version}</textapi>
        <title>
            <title>The Story and Proverbs of Ahikar the Wise</title>
            <type>{$format-type}</type>
        </title>
        <!-- this empty title element is necessary to force JSON to
        generate an array instead of a simple object. -->
        <title/>
        <collector>
            <role>collector</role>
            <name>Prof. Dr. theol. Kratz, Reinhard Gregor</name>
            <idref>
                <base>http://d-nb.info/gnd/</base>
                <id>115412700</id>
                <type>GND</type>
            </idref>
        </collector>
        <description>Main collection for the Ahikar project. Funded by DFG, 2019–2020. University of Göttingen</description>
        <annotationCollection>{$annotationCollection-uri}</annotationCollection>
        {$sequence}
    </object>
};

declare function t-coll:get-aggregation($collection-uri as xs:string)
as document-node() {
    doc($commons:agg || $collection-uri || ".xml")
};

(:~
 : Some "editions" that appear in the ore:aggregates list of a collection are
 : actually no editions; They lack an XML file.
 : 
 : In order to not have them included in the list of "actual" editions, they
 : have to be explicitly excluded.
 : 
 : @param $doc The root element of an aggregation object
 : @return A list of ore:aggregates without the manifests to be excluded
 : 
 :)
declare function t-coll:get-allowed-manifest-uris($aggregation-file as node())
as xs:string+ {
    let $not-allowed :=
        (
            "textgrid:3vp38"
        )
    let $allowed := 
        for $aggregate in $aggregation-file//ore:aggregates return
            $aggregate[@rdf:resource != $not-allowed]/@rdf:resource
    return
        for $uri in $allowed return
            t-coll:remove-textgrid-prefix($uri)
};

declare function t-coll:remove-textgrid-prefix($uri as xs:string)
as xs:string {
    replace($uri, "textgrid:", "")
};

declare function t-coll:get-metadata-file($uri as xs:string)
as document-node() {
    doc($commons:meta || $uri || ".xml")
};

declare function t-coll:make-sequence($collection-uri as xs:string,
    $server as xs:string)
as element(sequence)+ {
    let $aggregation := t-coll:get-aggregation($collection-uri)
    let $allowed-manifest-uris := t-coll:get-allowed-manifest-uris($aggregation/*)
    
    for $manifest-uri in $allowed-manifest-uris return
        let $manifest-metadata :=  t-coll:get-metadata-file($manifest-uri)
        let $id := t-coll:make-id($server, $collection-uri, $manifest-uri)
        let $type := t-coll:make-format-type($manifest-metadata)
        return
            <sequence>
                <id>{$id}</id>
                <type>{$type}</type>
            </sequence>
};

declare function t-coll:make-id($server as xs:string,
    $collection-uri as xs:string,
    $manifest-uri as xs:string)
as xs:string {
    $server || "/api/textapi/ahikar/" || $collection-uri || "/" || $manifest-uri || "/manifest.json"
};

declare function t-coll:get-format-type($metadata as document-node())
as xs:string {
    $metadata//tgmd:format[1]/string()
    => t-coll:make-format-type()
};

declare function t-coll:make-format-type($tgmd-format as xs:string)
as xs:string {
    switch ($tgmd-format)
        case "text/tg.aggregation+xml" return "collection"
        case "text/tg.edition+tg.aggregation+xml" return "manifest"
        default return "manifest"
};

declare function t-coll:make-annotationCollection-uri($server as xs:string,
    $collection-uri as xs:string)
as xs:string {
    $server || "/api/textapi/ahikar/" || $collection-uri || "/annotationCollection.json"
};
