xquery version "3.1";
(: 
 : This module is for preparing the HTML serialization of a
 : given TEI document or fragment.
 :)

module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";

(:~
 : Initiates the HTML serialization of a given page.
 :
 : @param $manifest-uri The unprefixed TextGrid URI of a document, e.g. '3rbmb'
 : @param $page The page to be rendered. This has to be the string value of a tei:pb/@n in the given document, e.g. '1a'
 : @return A div wrapper containing the rendered page
 :)
declare function tapi-html:get-html($tei-xml-uri as xs:string,
    $page as xs:string)
as element(div) {
    let $tei-xml-base-uri := $commons:data || $tei-xml-uri || ".xml"
    let $fragment :=
        if ($page) then
            tapi-html:get-page-fragment($tei-xml-base-uri, $page)
        else
            doc($tei-xml-base-uri)/*
    return
        tapi-html:get-html-from-fragment($fragment)
};


declare function tapi-html:get-page-fragment($tei-xml-base-uri as xs:string,
    $page as xs:string)
as element() {
    let $node := doc($tei-xml-base-uri)/*
        => tapi-html:add-IDs(),
        $start-node := $node//tei:pb[@n = $page and @facs],
        $end-node := tapi-html:get-end-node($start-node),
        $wrap-in-first-common-ancestor-only := false(),
        $include-start-and-end-nodes := false(),
        $empty-ancestor-elements-to-include := ("")
    return
        fragment:get-fragment-from-doc(
            $node,
            $start-node,
            $end-node,
            $wrap-in-first-common-ancestor-only,
            $include-start-and-end-nodes,
            $empty-ancestor-elements-to-include)
};


declare function tapi-html:add-IDs($nodes as node()*)
as node()* {
    for $node in $nodes return
        typeswitch ($node)
        
        case text() return
            $node
            
        case comment() return
            ()
            
        case processing-instruction() return
            $node
            
        default return
            element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
                attribute id {generate-id($node)},
                $node/@*,
                tapi-html:add-IDs($node/node())
            }
};


declare function tapi-html:get-end-node($start-node as element(tei:pb))
as element() {
    let $following-pb := $start-node/following::tei:pb[1][@facs]
    return
        if($following-pb) then
            $following-pb
        else
            $start-node/following::tei:ab[last()]
};


declare function tapi-html:get-html-from-fragment($fragment as element())
as element(xhtml:div) {
    let $stylesheet := doc("/db/apps/sade_assets/TEI-Stylesheets/html5/html5.xsl")
    return
        (: this wrapping is necessary in order to correctly set the namespace.
        otherwise, error XQST0070 is raised during the tests. :)
        element xhtml:div {
            attribute class {"tei_body"},
            transform:transform($fragment, $stylesheet, ())/xhtml:body//xhtml:div[@class = "tei_body"]/*
        }
};
