xquery version "3.1";

module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace tei2html="http://ahikar.sub.uni-goettingen.de/ns/tei2html" at "tei2html.xqm";

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
            commons:get-page-fragment($tei-xml-base-uri, $page)
        else
            doc($tei-xml-base-uri)/*
    return
        tapi-html:get-html-from-fragment($fragment)
};


declare function tapi-html:get-html-from-fragment($fragment as element())
as element(xhtml:div) {
    (: this wrapping is necessary in order to correctly set the namespace.
    otherwise, error XQST0070 is raised during the tests. :)
    element xhtml:div {
        attribute class {"tei_body"},
        tei2html:transform($fragment)/*
    }
};
