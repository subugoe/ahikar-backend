xquery version "3.1";

(: 
 : This module handles calls to the API on manifest level, e.g.
 : 
 : /textapi/ahikar/arabic-karshuni/3rx15/manifest.json
 :)

module namespace tapi-mani="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";


declare function tapi-mani:get-json($collection-type as xs:string,
    $manifest-uri as xs:string,
    $server as xs:string)
as element(object) {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        <object>
            <textapi>{$commons:version}</textapi>
            <id>{$server || "/api/textapi/ahikar/" || $collection-type || "/" || $manifest-uri || "/manifest.json"}</id>
            <label>{tapi-mani:get-manifest-title($manifest-uri)}</label>
            <license>{tapi-mani:get-license-info($tei-xml)}</license>
            {tapi-mani:make-metadata-objects($tei-xml)}
            <annotationCollection>{$server}/api/annotations/ahikar/{$collection-type}/{$manifest-uri}/annotationCollection.json</annotationCollection>
            {tapi-mani:make-sequences($collection-type, $manifest-uri, $server)}
        </object>
};

declare function tapi-mani:make-metadata-objects($tei-xml as document-node())
as element(metadata)+ {
    for $element in ("editor", "date", "origin", "location") return
        <metadata>
            {
                switch ($element)
                    case "editor" return tapi-mani:make-editors($tei-xml)
                    case "date" return tapi-mani:make-creation-date($tei-xml)
                    case "origin" return tapi-mani:make-origin($tei-xml)
                    case "location" return tapi-mani:make-current-location($tei-xml)
                    default return ()
            }
        </metadata>
};

declare function tapi-mani:make-sequences($collection-type as xs:string,
    $manifest-uri as xs:string,
    $server as xs:string)
as element(sequence)+ {
    let $valid-pages := tapi-mani:get-valid-page-ids($manifest-uri)
    return
        for $page in $valid-pages
        let $uri := "/api/textapi/ahikar/" || $collection-type || "/" || $manifest-uri || "-" ||  $page || "/latest/item.json"
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


declare function tapi-mani:make-editors($tei-xml as document-node())
as element()+ {
    let $editors := $tei-xml//tei:titleStmt//tei:editor
    return
        if (exists($editors)) then
            (
                <key>Editors</key>,
                <value>
                    {
                        let $value-strings :=
                            for $editor in $editors return
                                (
                                    normalize-space($editor/string()),
                                    if(not(index-of($editors, $editor) = count($editors))) then ", " else ()
                                )
                        return
                            string-join($value-strings, "")
                    }
                </value>
            )
        else
                (
                    <key>Editor</key>,
                    <value>none</value>
                )
};


declare function tapi-mani:make-creation-date($tei-xml as document-node())
as element()+ {
    let $creation-date := $tei-xml//tei:history//tei:date
    let $string :=
        if ($creation-date) then
            $creation-date/string()
        else
            "unknown"
    return
        (
            <key>Date of creation</key>,
            <value>{$string}</value>
        )
};


declare function tapi-mani:make-origin($tei-xml as document-node()) as 
element()+ {
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
        (
            <key>Place of origin</key>,
            <value>{$string}</value>
        )
};


declare function tapi-mani:make-current-location($tei-xml as document-node()) as
element()+ {
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
        (
            <key>Current location</key>,
            <value>{$string}</value>
        )
};

declare function tapi-mani:get-license-info($tei-xml as document-node())
as xs:string {
    let $target := $tei-xml//tei:licence/@target
    return
        tapi-mani:get-spdx-for-license($target)
};

declare function tapi-mani:get-spdx-for-license($target as xs:string?)
as xs:string {
    switch ($target)
        case "https://creativecommons.org/licenses/by-sa/4.0/" return "CC-BY-SA-4.0"
        default return "no license provided"
};
