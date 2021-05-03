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
import module namespace functx="http://www.functx.com";


declare function tapi-mani:get-json($collection-type as xs:string,
    $manifest-uri as xs:string,
    $server as xs:string)
as map() {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        map {
            "textapi": $commons:version/string(),
            "id": $server || "/api/textapi/ahikar/" || $collection-type || "/" || $manifest-uri || "/manifest.json",
            "label": tapi-mani:get-manifest-title($manifest-uri),
            "metadata": tapi-mani:make-metadata-objects($tei-xml),
            "support": tapi-mani:make-support-object($server),
            "license": tapi-mani:get-license-info($tei-xml),
            "annotationCollection": $server || "/api/annotations/ahikar/" || $collection-type || "/" || $manifest-uri || "/annotationCollection.json",
            "sequence": tapi-mani:make-sequences($collection-type, $manifest-uri, $server) 
        }
};

declare function tapi-mani:get-manifest-title($manifest-uri as xs:string)
as xs:string {
    let $metadata-file := commons:get-metadata-file($manifest-uri)
    return
        $metadata-file//tgmd:title/string()
};

declare function tapi-mani:make-metadata-objects($tei-xml as document-node())
as map()+ {
    tapi-mani:make-editors($tei-xml),
    tapi-mani:make-creation-date($tei-xml),
    tapi-mani:make-origin($tei-xml),
    tapi-mani:make-current-location($tei-xml)
};

declare function tapi-mani:make-sequences($collection-type as xs:string,
    $manifest-uri as xs:string,
    $server as xs:string)
as map()+ {
    let $valid-pages := tapi-mani:get-valid-page-ids($manifest-uri)
    return
            for $page in $valid-pages
            let $uri := "/api/textapi/ahikar/" || $collection-type || "/" || $manifest-uri || "-" ||  $page || "/latest/item.json"
            return
                map {
                    "id": $server || $uri,
                    "type": "item"
                }
};

declare function tapi-mani:get-valid-page-ids($manifest-uri as xs:string)
as xs:string+ {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        $tei-xml//tei:pb[@facs]/string(@n)
};




declare function tapi-mani:make-editors($tei-xml as document-node())
as map() {
    let $editors := $tei-xml//tei:titleStmt//tei:editor
    return
        map {
            "key": "Editors",
            "value": if (exists($editors)) then string-join($editors, ", ") else "none"
        }
};


declare function tapi-mani:make-creation-date($tei-xml as document-node())
as map() {
    let $creation-date := $tei-xml//tei:history//tei:date
    let $string :=
        if ($creation-date) then
            $creation-date/string()
        else
            "unknown"
    return
        map {
            "key": "Date of creation",
            "value": $string
        }
};


declare function tapi-mani:make-origin($tei-xml as document-node()) 
as map() {
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
        map {
            "key": "Place of origin",
            "value": $string
        }
};


declare function tapi-mani:make-current-location($tei-xml as document-node())
as map() {
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
        map {
            "key": "Current location",
            "value": $string
        }
};

declare function tapi-mani:get-license-info($tei-xml as document-node())
as array(*) {
    array {
        map {
            "id": 
                    let $target := $tei-xml//tei:licence/@target
                    return
                        if ($target = "https://creativecommons.org/licenses/by-sa/4.0/") then
                            "CC-BY-SA-4.0 (https://creativecommons.org/licenses/by-sa/4.0/legalcode)"
                        else
                            "no license provided"
        }
    }
};

declare function tapi-mani:make-support-object($server as xs:string)
as array(*) {
    array {
        map {
            "type": "css",
            "mime": "text/css",
            "url": $server || "/api/content/ahikar.css"
        },
        tapi-mani:make-fonts($server)
    }
};

declare function tapi-mani:make-fonts($server as xs:string)
as map(*)+ {
    for $doc in collection("/db/data/resources/fonts") return
        map {
            "type": "font",
            "mime": "font/otf",
            "url": $server || "/api/content/" || functx:substring-after-last(base-uri($doc), "/")
        }
};
