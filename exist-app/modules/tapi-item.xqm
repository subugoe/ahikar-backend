xquery version "3.1";

(: 
 : This module handles calls to the API on item level, e.g.
 : 
 : /textapi/ahikar/arabic-karshuni/3rx15-8a/latest/item.json
 :)

module namespace tapi-item="http://ahikar.sub.uni-goettingen.de/ns/tapi/item";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace functx="http://www.functx.com";
import module namespace tapi-img="http://ahikar.sub.uni-goettingen.de/ns/tapi/images" at "tapi-img.xqm";


declare function tapi-item:get-json($collection-type as xs:string,
    $manifest-uri as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    map {
        "textapi": $commons:version/string(),
        "title": tapi-item:make-title-object($manifest-uri),
        "type": "page",
        "n": $page,
        "content": $server || "/api/content/" || commons:get-xml-uri($manifest-uri) || "-" || $page || ".html",
        "content-type": "application/xhtml+xml",
        "lang": tapi-item:make-language-array($manifest-uri),
        "langAlt": tapi-item:make-langAlt-array($manifest-uri),
        "x-langString": tapi-item:get-language-string($manifest-uri),
        "image": tapi-item:make-image-info($manifest-uri, $page, $server),
        "annotationCollection": 
            $server || "/api/annotations/ahikar/" || $collection-type || "/" || 
            $manifest-uri || "/" || $page || "/annotationCollection.json"
    } 
};


declare function tapi-item:make-title-object($manifest-uri as xs:string)
as item() {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $title :=
        $tei-xml//tei:title[@type = "main"]/string()
        => normalize-space()
    let $type := $tei-xml//tei:title/@type/string()
    return
        array {
            map {
                "title": $title,
                "type": $type
            }
        }
};


declare function tapi-item:make-language-array($manifest-uri as xs:string)
as item() {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $languages := $tei-xml//tei:language[@xml:base = "https://iso639-3.sil.org/code/"]
    return
        array {
            for $lang in $languages return
                $lang/@ident/string()
        }
};

declare function tapi-item:make-langAlt-array($manifest-uri as xs:string)
as item() {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $languages := $tei-xml//tei:language[not(@xml:base = "https://iso639-3.sil.org/code/")]
    return
        array {
            for $lang in $languages return
                $lang/@ident/string()
        }
};


declare function tapi-item:get-language-string($manifest-uri as xs:string)
as xs:string {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $langString :=
        for $lang in $tei-xml//tei:language/text()
        order by $lang
        return $lang
    return
        string-join($langString, ", ")
};

declare function tapi-item:make-image-info($manifest-uri as xs:string,
    $page as xs:string,
    $server as xs:string)
as map() {
    map {
        "id": tapi-item:make-facsimile-id($manifest-uri, $page, $server),
        "license": tapi-item:make-license-info-for-img($manifest-uri, $page)
    }
};


declare function tapi-item:make-facsimile-id($manifest-uri as xs:string,
    $page as xs:string,
    $server as xs:string)
as xs:string {
    let $facsimile-uri := tapi-img:get-facsimile-uri-for-page($manifest-uri, $page)
    return
        if (tapi-img:has-manifest-tile($manifest-uri)) then
            tapi-item:make-url-for-double-page-image($facsimile-uri, $manifest-uri, $page, $server)
        else
            tapi-item:make-url-for-single-page-image($facsimile-uri, $server)
};

declare function tapi-item:make-url-for-single-page-image($facsimile-uri as xs:string,
    $server as xs:string)
as xs:string {
    tapi-item:make-img-url-prefix($facsimile-uri, $server)
};

declare function tapi-item:make-url-for-double-page-image($facsimile-uri as xs:string,
    $manifest-uri as xs:string,
    $page as xs:string,
    $server as xs:string)
as xs:string {
    let $image-section := tapi-img:get-relevant-image-section($manifest-uri, $page)
    return
        tapi-item:make-img-url-prefix($facsimile-uri, $server) || "/" || $image-section
};

declare function tapi-item:make-img-url-prefix($facsimile-uri as xs:string,
    $server as xs:string)
as xs:string {
    $server || "/api/images/" || tapi-item:make-restricted-or-public-path-component($facsimile-uri) || $facsimile-uri
};

declare function tapi-item:make-restricted-or-public-path-component($facsimile-uri as xs:string)
as xs:string {
    if (tapi-img:is-image-public($facsimile-uri)) then
        "public/"
    else
        "restricted/"
};

declare function tapi-item:make-license-info-for-img($manifest-uri as xs:string,
    $page as xs:string)
as map() {
    let $facsimile-uri := tapi-img:get-facsimile-uri-for-page($manifest-uri, $page)
    let $img-metadata := tapi-img:get-img-metadata($facsimile-uri)[2]
    let $notes := $img-metadata//tgmd:notes
        => substring-after("access. ")
    let $id :=
        if (matches($notes, "CC")) then
            functx:get-matches($notes, "CC.*?\.\d")
            => replace(" ", "-")
        else if (matches(lower-case($notes), "public domain")) then
            "Public domain"
        else
            "Copyright"
    return
        map {
            "id": $id,
            "notes": $notes
        }
};
