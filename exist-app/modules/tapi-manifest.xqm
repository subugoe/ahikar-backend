xquery version "3.1";

(: 
 : This module handles calls to the API on manifest level, e.g.
 : 
 : /textapi/ahikar/3r9ps/3rx15/manifest.json
 :)

module namespace tapi-mani="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";


declare function tapi-mani:get-json($collection-uri as xs:string,
    $manifest-uri as xs:string,
    $server as xs:string)
as element(object) {
    <object>
        <textapi>{$commons:version}</textapi>
        <id>{$server || "/api/textapi/ahikar/" || $collection-uri || "/" || $manifest-uri || "/manifest.json"}</id>
        <label>{tapi-mani:get-manifest-title($manifest-uri)}</label>
        { 
            tapi-mani:make-editors($manifest-uri),
            tapi-mani:make-creation-date($manifest-uri),
            tapi-mani:make-origin($manifest-uri),
            tapi-mani:make-current-location($manifest-uri)
        }
        <license>CC0-1.0</license>
        <annotationCollection>{$server}/api/annotations/ahikar/{$collection-uri}/{$manifest-uri}/annotationCollection.json</annotationCollection>
        {tapi-mani:make-sequences($collection-uri, $manifest-uri, $server)}
    </object>
};


declare function tapi-mani:make-sequences($collection-uri as xs:string,
    $manifest-uri as xs:string,
    $server as xs:string)
as element(sequence)+ {
    let $valid-pages := tapi-mani:get-valid-page-ids($manifest-uri)
    return
        for $page in $valid-pages
        let $uri := "/api/textapi/ahikar/" || $collection-uri || "/" || $manifest-uri || "-" ||  $page || "/latest/item.json"
        return
            <sequence>
                <id>{$server}{$uri}</id>
                <type>item</type>
            </sequence>
};

declare function tapi-mani:get-valid-page-ids($manifest-uri as xs:string)
as xs:string+ {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        $tei-xml//tei:pb[@facs]/string(@n)
};

declare function tapi-mani:get-manifest-title($manifest-uri as xs:string)
as xs:string {
    let $metadata-file := commons:get-metadata-file($manifest-uri)
    return
        $metadata-file//tgmd:title/string()
};


declare function tapi-mani:make-editors($manifest-uri as xs:string)
as element(x-editor)+ {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $editors := $tei-xml//tei:titleStmt//tei:editor
    return
        if (exists($editors)) then
            for $editor in $editors
            return
                <x-editor>
                    <role>editor</role>
                    <name>{$editor/string()}</name>
                </x-editor>
        else
            <x-editor>
                <name>none</name>
            </x-editor>
};


declare function tapi-mani:make-creation-date($manifest-uri as xs:string)
as element(x-date) {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $creation-date := $tei-xml//tei:history//tei:date
    let $string :=
        if ($creation-date) then
            $creation-date/string()
        else
            "unknown"
    return
        <x-date>{$string}</x-date>
};


declare function tapi-mani:make-origin($manifest-uri as xs:string) as 
element(x-origin) {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $country := $tei-xml//tei:history//tei:country
    let $place := $tei-xml//tei:history//tei:placeName
    let $string :=
        if ($country and $place) then
            $place/string() || ", " || $country/string()
        else if ($country) then
            $country/string()
        else if($place) then
            $place/string()
        else
            "unknown"
    return
        <x-origin>{$string}</x-origin>
};


declare function tapi-mani:make-current-location($manifest-uri as xs:string) as
element(x-location) {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $institution := $tei-xml//tei:msIdentifier//tei:institution
    let $country := $tei-xml//tei:msIdentifier//tei:country
    let $string :=
        if ($country and $institution) then
            $institution || ", " || $country
        else if ($country) then
            $country/string()
        else if($institution) then
            $institution/string()
        else
            "unknown"
    return
        <x-location>{$string}</x-location>

};
