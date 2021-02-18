xquery version "3.1";

(: 
 : This module handles calls to the API on collection level, e.g.
 : 
 : /textapi/ahikar/3r9ps/collection.json
 :)

module namespace tapi-coll="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";

declare variable $tapi-coll:uris :=
    map {
        "syriac": if (doc-available($commons:agg || "3r84g.xml")) then "3r84g" else "sample_lang_aggregation_syriac",
        "arabic-karshuni": (
            if (doc-available($commons:agg || "3r9ps.xml")) then "3r9ps" else "sample_lang_aggregation_arabic",
            if (doc-available($commons:agg || "3r84h.xml")) then "3r84h" else "sample_lang_aggregation_karshuni"),
        "sample": "sample_collection_tbd"
    };
    
declare function tapi-coll:get-uris($collection-type as xs:string)
as xs:string+ {
    map:get($tapi-coll:uris, $collection-type)
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
 : @param $collection-type The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable.
 : @return An object element containing all necessary information
 :)
declare function tapi-coll:get-json($collection-type as xs:string,
    $server as xs:string)
as item()+ {
    let $collection-string := tapi-coll:get-collection-string($collection-type)
    let $sequence := tapi-coll:make-sequence($collection-type, $server)
    let $annotationCollection-uri := tapi-coll:make-annotationCollection-uri($server, $collection-type)
    
    return
        <object>
            <textapi>{$commons:version}</textapi>
            <title>
                <title>The Story and Proverbs of Ahikar the Wise</title>
                <type>main</type>
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
            <description>{$collection-string} collection for the Ahiqar project. Funded by DFG, 2019–2020. University of Göttingen</description>
            <annotationCollection>{$annotationCollection-uri}</annotationCollection>
            {$sequence}
        </object>
};

declare function tapi-coll:get-collection-string($collection-type as xs:string)
as xs:string {
    switch ($collection-type)
        case "syriac" return "Syriac"
        case "arabic-karshuni" return "Arabic/Karshuni"
        case "sample" return "Sample Collection"
        default return error("D001", "Unknown collection type " || $collection-type)
};


declare function tapi-coll:get-aggregations($uris as xs:string+)
as document-node()+ {
    for $uri in $uris return
        doc($commons:agg || $uri || ".xml")
};


(:~
 : Some "editions" that appear in the ore:aggregates list of a collection are
 : actually no editions; They lack an XML file.
 : 
 : In order to not have them included in the list of "actual" editions, they
 : have to be explicitly excluded.
 : 
 : @param $aggregatins The root element(s) of one or more aggregation objects
 : @return A list of ore:aggregates without the manifests to be excluded
 : 
 :)
declare function tapi-coll:get-allowed-manifest-uris($aggregations as node()+)
as xs:string+ {
    let $not-allowed :=
        (
            "textgrid:3vp38"
        )
    let $allowed := 
        for $aggregation-file in $aggregations return
            for $aggregate in $aggregation-file//ore:aggregates return
                $aggregate[@rdf:resource != $not-allowed]/@rdf:resource
    return
        for $uri in $allowed return
            tapi-coll:remove-textgrid-prefix($uri)
};

declare function tapi-coll:remove-textgrid-prefix($uri as xs:string)
as xs:string {
    replace($uri, "textgrid:", "")
};

declare function tapi-coll:make-sequence($collection-type as xs:string,
    $server as xs:string)
as element(sequence)+ {
    let $uris := tapi-coll:get-uris($collection-type)
    let $aggregations := tapi-coll:get-aggregations($uris)
    let $allowed-manifest-uris := tapi-coll:get-allowed-manifest-uris($aggregations)
    for $manifest-uri in $allowed-manifest-uris return
        let $manifest-metadata :=  commons:get-metadata-file($manifest-uri)
        let $id := tapi-coll:make-id($server, $collection-type, $manifest-uri)
        let $type := tapi-coll:make-format-type($manifest-metadata)
        return
            <sequence>
                <id>{$id}</id>
                <type>{$type}</type>
            </sequence>
};

declare function tapi-coll:make-id($server as xs:string,
    $collection-type as xs:string,
    $manifest-uri as xs:string)
as xs:string {
    $server || "/api/textapi/ahikar/" || $collection-type || "/" || $manifest-uri || "/manifest.json"
};

declare function tapi-coll:get-format-type($metadata as document-node())
as xs:string {
    $metadata//tgmd:format[1]/string()
    => tapi-coll:make-format-type()
};

declare function tapi-coll:make-format-type($tgmd-format as xs:string)
as xs:string {
    switch ($tgmd-format)
        case "text/tg.aggregation+xml" return "collection"
        case "text/tg.edition+tg.aggregation+xml" return "manifest"
        default return "manifest"
};

declare function tapi-coll:make-annotationCollection-uri($server as xs:string,
    $collection-type as xs:string)
as xs:string {
    $server || "/api/annotations/ahikar/" || $collection-type || "/annotationCollection.json"
};
