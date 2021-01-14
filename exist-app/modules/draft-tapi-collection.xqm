xquery version "3.1";

module namespace d="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection-draft";

declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";

declare variable $d:uris :=
    map {
        "syriac": if (doc-available($commons:agg || "3r84g.xml")) then "3r84g" else "sample_lang_aggregation_syriac",
        "arabic-karshuni": (
            if (doc-available($commons:agg || "3r9ps.xml")) then "3r9ps" else "sample_lang_aggregation_arabic",
            if (doc-available($commons:agg || "3r84h.xml")) then "3r84h" else "sample_lang_aggregation_karshuni")
    };
    
declare function d:get-uris($collection-type as xs:string)
as xs:string+ {
    map:get($d:uris, $collection-type)
};


declare function d:get-json($collection-type as xs:string,
    $server as xs:string)
as item()+ {
    let $collection-string := d:get-collection-string($collection-type)
    let $sequence := d:make-sequence($collection-type, $server)
    let $annotationCollection-uri := d:make-annotationCollection-uri($server, $collection-type)
    
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

declare function d:get-collection-string($collection-type as xs:string)
as xs:string {
    switch ($collection-type)
        case "syriac" return "Syriac"
        case "arabic-karshuni" return "Arabic/Karshuni"
        default return error("D001", "Unknown collection type " || $collection-type)
};

declare function d:make-sequence($collection-type as xs:string,
    $server as xs:string)
as element(sequence)+ {
    let $uris := d:get-uris($collection-type)
    let $aggregations := d:get-aggregations($uris)
    let $allowed-manifest-uris := d:get-allowed-manifest-uris($aggregations)
    for $manifest-uri in $allowed-manifest-uris return
        let $manifest-metadata :=  commons:get-metadata-file($manifest-uri)
        let $id := d:make-id($server, $collection-type, $manifest-uri)
        let $type := d:make-format-type($manifest-metadata)
        return
            <sequence>
                <id>{$id}</id>
                <type>{$type}</type>
            </sequence>
};

declare function d:get-aggregations($uris as xs:string+)
as document-node()+ {
    for $uri in $uris return
        doc($commons:agg || $uri || ".xml")
};

declare function d:get-allowed-manifest-uris($aggregations as node()+)
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
            d:remove-textgrid-prefix($uri)
};

declare function d:remove-textgrid-prefix($uri as xs:string)
as xs:string {
    replace($uri, "textgrid:", "")
};

declare function d:make-id($server as xs:string,
    $collection-type as xs:string,
    $manifest-uri as xs:string)
as xs:string {
    $server || "/api/textapi/ahikar/" || $collection-type || "/" || $manifest-uri || "/manifest.json"
};

declare function d:get-format-type($metadata as document-node())
as xs:string {
    $metadata//tgmd:format[1]/string()
    => d:make-format-type()
};

declare function d:make-format-type($tgmd-format as xs:string)
as xs:string {
    switch ($tgmd-format)
        case "text/tg.aggregation+xml" return "collection"
        case "text/tg.edition+tg.aggregation+xml" return "manifest"
        default return "manifest"
};

declare function d:make-annotationCollection-uri($server as xs:string,
    $collection-type as xs:string)
as xs:string {
    $server || "/api/annotations/ahikar/" || $collection-type || "/annotationCollection.json"
};
