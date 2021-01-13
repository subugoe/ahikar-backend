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
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";

declare function tapi-img:has-manifest-tile($manifest-uri as xs:string)
as xs:boolean {
    exists(tapi-img:get-tile-uri($manifest-uri))
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

declare function tapi-img:get-tile-uri($manifest-uri as xs:string)
as xs:string* {
    let $manifest-doc := commons:get-aggregation($manifest-uri)
    let $aggregated := $manifest-doc//ore:aggregates
    for $element in $aggregated return
        let $stripped-uri := substring-after($element/@rdf:resource/string(), "textgrid:")
        return
            if (tapi-img:is-tile-available($stripped-uri)) then
                $stripped-uri
            else
                ()
};

declare function tapi-img:get-tile($manifest-uri as xs:string)
as document-node()? {
    tapi-img:get-tile-uri($manifest-uri)
    => tapi-img:open-tile()
};

declare function tapi-img:open-tile($uri as xs:string)
as document-node() {
    doc($commons:tile || $uri || ".xml")
};

declare function tapi-img:get-facsimile-uri-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        $tei-xml//tei:pb[@n = $page]/@facs
        => substring-after("textgrid:")
};

declare function tapi-img:get-xml-id-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        $tei-xml//tei:pb[@n = $page]/@xml:id/string()
};

declare function tapi-img:get-shape-id($manifest-uri as xs:string,
    $page-id as xs:string)
as xs:string {
    let $tile := tapi-img:get-tile($manifest-uri)
    let $link-element := $tile//tei:link[ends-with(@targets, $page-id)]
    return
        (:@targets has the following form:
        #shape-1 textgrid:ahiqar_sample.3#a1 :)
        tokenize($link-element/@targets, " ")[1]
        => replace("#", "")
};

declare function tapi-img:get-svg-rect($tile as document-node(),
    $shape-id as xs:string)
as element(svg:rect) {
    $tile//svg:rect[@id = $shape-id]
};

declare function tapi-img:get-svg-section-dimensions-as-string($svg as element(svg:rect))
as xs:string {
    let $x-offset := local:truncate($svg/@x)
    let $y-offset := local:truncate($svg/@y)
    let $width := local:truncate($svg/@width)
    let $height := local:truncate($svg/@height)
    return
        string-join(($x-offset, $y-offset, $width, $height), ",")
};

declare function local:truncate($number-as-string as attribute())
as xs:string {
  $number-as-string
    => substring-before("%")
    => xs:decimal()
    => format-number("0.00") (: will round last number; converts to string :)
};

declare function tapi-img:get-relevant-image-section($manifest-uri as xs:string,
    $page-uri as xs:string)
as xs:string {
    let $page-id := tapi-img:get-xml-id-for-page($manifest-uri, $page-uri)
    let $shape-id := tapi-img:get-shape-id($manifest-uri, $page-id)
    let $tile := tapi-img:get-tile($manifest-uri)
    let $svg := tapi-img:get-svg-rect($tile, $shape-id)
    return
        tapi-img:get-svg-section-dimensions-as-string($svg)
};
