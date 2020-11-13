xquery version "3.1";

(: 
 : This module handles calls to the API on item level, e.g.
 : 
 : /textapi/ahikar/3r9ps/3rx15-8a/latest/item.json
 :)

module namespace tapi-item="http://ahikar.sub.uni-goettingen.de/ns/tapi/item";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";


declare function tapi-item:get-json($collection-uri as xs:string,
    $manifest-uri as xs:string,
    $page as xs:string,
    $server as xs:string)
as element(object) {
    <object>
        <textapi>{$commons:version}</textapi>
        <title>{tapi-item:make-title($manifest-uri)}</title>
        <type>page</type>
        <n>{$page}</n>
        <content>{$server}/api/content/{commons:get-xml-uri($manifest-uri)}-{$page}.html</content>
        <content-type>application/xhtml+xml</content-type>
        {tapi-item:make-language-elements($manifest-uri)}
        <x-langString>{tapi-item:get-language-string($manifest-uri)}</x-langString>
        <image>
            <id>{tapi-item:make-facsimile-id($manifest-uri, $page, $server)}</id>
        </image>
        <annotationCollection>{$server}/api/annotations/ahikar/{$collection-uri}/{$manifest-uri}/{$page}/annotationCollection.json</annotationCollection>
    </object>
};


declare function tapi-item:make-title($manifest-uri)
as xs:string {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        $tei-xml//tei:title[@type = "main"]/string()
};


declare function tapi-item:make-language-elements($manifest-uri as xs:string)
as element()+ {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    let $languages := $tei-xml//tei:language
    return
        for $lang in $languages return
            if ($lang[@xml:base = "https://iso639-3.sil.org/code/"]) then
                element lang {$lang/@ident/string()}
            else
                element langAlt {$lang/@ident/string()}
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


declare function tapi-item:make-facsimile-id($manifest-uri as xs:string,
    $page as xs:string,
    $server as xs:string)
as xs:string {
    let $image-uri := tapi-item:get-facsimile-uri-for-page($manifest-uri, $page)
    return
        $server || "/api/images/" || $image-uri
};


declare function tapi-item:get-facsimile-uri-for-page($manifest-uri as xs:string,
    $page as xs:string)
as xs:string {
    let $tei-xml := commons:get-tei-xml-for-manifest($manifest-uri)
    return
        $tei-xml//tei:pb[@n = $page]/@facs
        => substring-after("textgrid:")
};
