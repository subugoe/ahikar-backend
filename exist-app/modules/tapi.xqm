xquery version "3.1";

(:~
 : This module provides the TextAPI for Ahiqar. For an extensive explanation of
 : the whole Ahiqar specific implementation of the generic TextAPI see the link
 : to the API docs.
 :
 : @author Mathias Göbel
 : @author Michelle Weidling
 : @version 1.9.0
 : @since 0.0.0
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/
 : :)

module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi";

declare namespace expkg="http://expath.org/ns/pkg";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery" at "fragment.xqm";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";

declare variable $tapi:version := "1.9.0";
declare variable $tapi:server := if(requestr:hostname() = "existdb") then doc("../expath-pkg.xml")/*/@name => replace("/$", "") else "http://localhost:8094/exist/restxq";
declare variable $tapi:baseCollection := "/db/apps/sade/textgrid";
declare variable $tapi:dataCollection := $tapi:baseCollection || "/data/";
declare variable $tapi:metaCollection := $tapi:baseCollection || "/meta/";
declare variable $tapi:aggCollection := $tapi:baseCollection || "/agg/";
declare variable $tapi:appHome := "/db/apps/ahikar";

declare variable $tapi:responseHeader200 :=
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>;

(:~
 : Shows information about the currently installed application.
 :
 : @return The content of the app's expath-pkg.xml and repo.xml as JSON
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/info")
    %output:method("json")
function tapi:info-rest()
as item()+ {
    $tapi:responseHeader200,
    tapi:info()
};

(:~
 : Retrieves info about the Ahiqar app.
 :
 : @return element(descriptors)
 :)
declare function tapi:info()
as element(descriptors) {
    <descriptors>
        <request>
            <scheme>{ requestr:scheme() }</scheme>
            <hostname>{ requestr:hostname() }</hostname>
            <uri>{ requestr:uri() }</uri>
        </request>
        {
            tapi:remove-whitespaces(doc($tapi:appHome || "/expath-pkg.xml")),
            tapi:remove-whitespaces(doc($tapi:appHome || "/repo.xml"))
        }
    </descriptors>
};

(:~ 
 : Removes all line breaks and surplus white spaces from XML files.
 : This way we avoid producing a littered JSON with fields that only contain
 : white space text.
 : 
 : @author Michelle Weidling
 : @param $doc The XML document to be transformed
 : @return $doc but without indentation
 :)
declare function tapi:remove-whitespaces($doc as document-node()) as document-node() {
    $doc => serialize() => replace("[\s]{2,}", "") => replace("[\n]", "") => parse-xml()
};

(:~
 : Returns information about a given collection.
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @param $collection The unprefixed TextGrid URI of a collection, e.g. '3r132'
 : @return A collection object as JSON
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection}/collection.json")
    %output:method("json")
function tapi:collection-rest($collection as xs:string)
as item()+ {
    $tapi:responseHeader200,
    tapi:collection($collection, $tapi:server)
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
 : @param $collection The unprefixed TextGrid URI of a collection. For Ahiqar's main collection this is '3r132'.
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable.
 : @return An object element containing all necessary information
 :)
declare function tapi:collection($collection as xs:string, $server as xs:string)
as item()+ {
    let $aggregation := doc($tapi:aggCollection || $collection || ".xml")
    let $meta := collection($tapi:metaCollection)//tgmd:textgridUri[starts-with(., "textgrid:" || $collection)]/root()
    let $sequence :=
        for $i in $aggregation//*:aggregates/string(@*:resource)
            let $metaObject := collection($tapi:metaCollection)//tgmd:textgridUri[starts-with(., $i)]/root()
            return
                <sequence>
                    <id>{$server}/api/textapi/ahikar/{$collection}/{substring-after($i, ":")}/manifest.json</id>
                    <type>{
                        if($collection = "3r84g")
                        then
                            "manifest"
                        else
                            ($metaObject//tgmd:format)[1]
                            => string()
                            => tapi:type()
                    }</type>
                </sequence>
    return
    <object>
        <textapi>{$tapi:version}</textapi>
        <title>
            <title>The Story and Proverbs of Ahikar the Wise</title>
            <type>{$meta//tgmd:format => string() => tapi:type()}</type>
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
        <description>Main collection for the Ahikar project. Funded by DFG, 2019–2020. University of Göttingen</description>
        <annotationCollection>{$server}/api/textapi/ahikar/{$collection}/annotationCollection.json</annotationCollection>
        {$sequence}
    </object>
};


(:~
 : Returns information about a given document as specified at
 : https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest.
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest
 : @param $collection The unprefixed TextGrid URI of a collection, e.g. '3r84g'
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r679'
 : @return An object element containing all necessary information about a manifest object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection}/{$document}/manifest.json")
    %output:method("json")
function tapi:manifest-rest($collection as xs:string, $document as xs:string)
as item()+ {
    $tapi:responseHeader200,
    tapi:manifest($collection, $document, $tapi:server)
};


(:~
 : Returns information about an edition object (i.e. an aggregation) which holds
 : an XML document as well as the facsimiles.
 : 
 : In contrast to the generic TextAPI specs on manifest objects we do not provide an
 : ID at this point. One reason is the TextGrid metadata model, the other is FRBR.
 : 
 : @param $collection The URI of the document's parent collection, e.g. '3r9ps'
 : @param $document The URI of an edition object, e.g. '3r177'
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable and defaults to $tapi:server.
 : @return An object element containing all necessary information about a manifest object
 :)
declare function tapi:manifest($collection as xs:string, $document as xs:string,
$server as xs:string)
as element(object) {
    let $aggNode := doc($tapi:aggCollection || $document || ".xml")
    let $metaNode := doc($tapi:baseCollection || "/meta/" || $document || ".xml")
    let $documentUri := $aggNode//ore:aggregates[1]/@rdf:resource => substring-after(":")
    let $documentNode := doc($tapi:dataCollection || $documentUri || ".xml")
    let $sequence :=
        for $page in $documentNode//tei:pb[@facs]/string(@n)
        let $uri := "/api/textapi/ahikar/" || $collection || "/" || $document || "-" ||  $page || "/latest/item.json"
        return
            <sequence>
                <id>{$server}{$uri}</id>
                <type>item</type>
            </sequence>
    let $id := $server || "/api/textapi/ahikar/" || $collection || "/" || $document || "/manifest.json"
            
    return
    <object>
        <textapi>{$tapi:version}</textapi>
        <id>{$id}</id>
        <label>{string($metaNode//tgmd:title)}</label>
        {
            tapi:make-editors($documentNode),
            tapi:make-date($documentNode),
            tapi:make-origin($documentNode),
            tapi:make-location($documentNode)
        }
        <license>CC0-1.0</license>
        <annotationCollection>{$server}/api/textapi/ahikar/{$collection}/{$document}/annotationCollection.json</annotationCollection>
        {$sequence}
    </object>
};


(:~ 
 : Creates the necessary information about editors.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#actor-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-editor element with all information necessary for an Actor Object.
 :)
declare function tapi:make-editors($documentNode as document-node()) as element(x-editor)* {
    let $role := "editor"
    for $editor in $documentNode//tei:titleStmt//tei:editor
    return
        <x-editor>
            <role>{$role}</role>
            <name>{$editor/string()}</name>
        </x-editor>
};

(:~
 : Creates the necessary information about a manuscript's origin from the TEI
 : header.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#manifest-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-origin element containing a descriptive string
 :)
declare function tapi:make-origin($documentNode as document-node()) as 
element(x-origin)? {
    let $country := $documentNode//tei:history//tei:country
    let $place := $documentNode//tei:history//tei:placeName
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


(:~
 : Creates the necessary information about a manuscript's creation date from the
 : TEI header.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#manifest-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-date element containing a descriptive string
 :)
declare function tapi:make-date($documentNode as document-node()) as
element(x-date)? {
    let $date := $documentNode//tei:history//tei:date
    let $string :=
        if ($date) then
            $date/string()
        else
            "unknown"
    return
        <x-date>{$string}</x-date>
};


(:~
 : Creates the necessary information about a manuscript's current location from
 : the TEI header.
 : 
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/#manifest-object
 : @param $documentNode The opened TEI file of the current manifest
 : @return An x-location element containing a descriptive string
 :)
declare function tapi:make-location($documentNode as document-node()) as
element(x-location) {
    let $institution := $documentNode//tei:msIdentifier//tei:institution
    let $country := $documentNode//tei:msIdentifier//tei:country
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


(:~ 
 : Returns the API endpoints of all pages of the manuscript.
 : Since we also have transliterations, only "original" pages (i.e. the ones
 : with a facsimile) are considered for the endpoints.
 : 
 : @param $documentNode The opened TEI file of the current manifest
 : @retun A sequence of sequence elements
 :)
declare function tapi:make-sequence($documentNode as document-node()) as
element(sequence)+ {
    for $page in $documentNode//tei:pb[@facs]/string(@n)
        let $uri := "/api/textapi/ahikar/" || $collection || "/" || $document || "-" ||  $page || "/latest/item.json"
        return
            <sequence>
                <id>{$server}{$uri}</id>
                <type>item</type>
            </sequence>
};

(:~
 : Returns information about a given page in a document. This is mainly compliant
 : with the SUB TextAPI, but has the following additions:
 :  * the division number, 'n', is mandatory
 :  * 'image' is mandatory since every page has a facsimile
 : 
 : The parameter $collection is actually not necessary but introduced to keep
 : the structure of the API clear.
 :
 : Sample call to API: /api/textapi/ahikar/3r17c/3r1pq-147a/latest/item.json
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#item
 : @param $collection The unprefixed TextGrid URI of a collection, e.g. '3r17c'
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r1pq'
 : @param $page A page number as encoded in a tei:pb/@n, e.g. '147a'
 : @return Information about a page
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection}/{$document}-{$page}/latest/item.json")
    %output:method("json")
function tapi:item-rest($collection as xs:string, $document as xs:string,
$page as xs:string) as item()+ {
    $tapi:responseHeader200,
    tapi:item($collection, $document, $page, $tapi:server)
};


(:~
 : Returns information about a given page.
 :
 : @param $document The unprefixed TextGrid URI of a collection, e.g. '3r9ps'
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r1pq'
 : @param $page A page number as encoded in a tei:pb/@n, e.g. '147a'
 : @param $server A string indicating the server. This parameter has been introduced to make this function testable and defaults to $tapi:server.
 : @return An object element containing all necessary information about an item
 :)
declare function tapi:item($collection as xs:string, $document as xs:string,
$page as xs:string, $server as xs:string) 
as element(object) {
    let $aggNode := doc($tapi:aggCollection || $document || ".xml")
    let $teiUri :=
        if($aggNode)
            then $aggNode//ore:aggregates[1]/@rdf:resource => substring-after(":")
        else $document
    let $image := doc($tapi:dataCollection || $teiUri || ".xml")//tei:pb[@n = $page]/@facs => substring-after("textgrid:")
    
    let $xml := doc($tapi:dataCollection || $teiUri || ".xml")
    let $title := $xml//tei:title[@type = "main"]/string()
    let $iso-languages := 
        $xml//tei:language[@xml:base = "https://iso639-3.sil.org/code/"]/@ident/string()
    let $alt-languages :=
        $xml//tei:language[not(@xml:base = "https://iso639-3.sil.org/code/")]/@ident/string()
    let $langString :=
        for $lang in $xml//tei:language/text()
        order by $lang
        return $lang
    let $langString := string-join($langString, ", ")
    
    return
    <object>
        <textapi>{$tapi:version}</textapi>
        <title>{$title}</title>
        <type>page</type>
        <n>{$page}</n>
        <content>{$server}/api/content/{$teiUri}-{$page}.html</content>
        <content-type>application/xhtml+xml</content-type>
        {
            for $lang in $iso-languages return
                element lang {$lang}
        }
        {
            for $lang in $alt-languages return
                element langAlt {$lang}
        }
        <x-langString>{$langString}</x-langString>
        <image>
            <id>{$server}/api/images/{$image}</id>
        </image>
        <annotationCollection>{$server}/api/textapi/ahikar/{$collection}/{$document}-{$page}/annotationCollection.json</annotationCollection>
    </object>
};


(:~
 : Returns an HTML rendering of a given page.
 : 
 : Since we only return a fragment of an HTML page which can be integrated in a
 : viewer or the like, we chose XML as output method in order to avoid setting
 : a DOCTYPE on a fragment.
 :
 : Sample call to API: /content/3rbmb-1a.html
 :
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3rbmb'
 : @param $page The page to be rendered. This has to be the string value of a tei:pb/@n in the given document, e.g. '1a'
 : @return A response header as well as the rendered HTML page
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/{$document}-{$page}.html")
    %output:method("xml")
    %output:indent("no")
function tapi:content-rest($document as xs:string, $page as xs:string)
as item()+ {
    $tapi:responseHeader200,
    tapi:content($document, $page)
};


(:~
 : Initiates the HTML serialization of a given page.
 :
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3rbmb'
 : @param $page The page to be rendered. This has to be the string value of a tei:pb/@n in the given document, e.g. '1a'
 : @return A div wrapper containing the rendered page
 :)
declare function tapi:content($document as xs:string, $page as xs:string)
as element(div) {
    let $documentPath := $tapi:dataCollection || $document || ".xml"
    let $TEI :=
        if($page)
        then
            let $node := doc($documentPath)/* => tapi:add-IDs(),
                $start-node := $node//tei:pb[@n = $page and @facs],
                $end-node :=
                    let $followingPb := $node//tei:pb[@n = $page and @facs]/following::tei:pb[1][@facs]
                    return
                        if($followingPb)
                        then $followingPb
                        else $node//tei:pb[@n = $page and @facs]/following::tei:ab[last()],
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
        else doc($documentPath)/*
    let $stylesheet := doc("/db/apps/sade_assets/TEI-Stylesheets/html5/html5.xsl")
    let $transform := transform:transform($TEI, $stylesheet, ())/xhtml:body//xhtml:div[@class = "tei_body"]
    return
        <div>
            {$transform}
        </div>
};


(:~
 : Returns an image belonging to a given URI. This function doesn't work locally
 : unless you have all necessary login information filled in at ahikar.env.
 : 
 : Since the images of the Ahikar project aren't publicly available, this
 : function cannot be tested by unit tests.
 :
 : @param $uri The unprefixed TextGrid URI of an image, e.g. '3r1pr'
 : @return The image as binary
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/images/{$uri}")
    %rest:produces("image/jpeg")
    %output:method("binary")
function tapi:images-rest($uri as xs:string)
as item()+ {
    $tapi:responseHeader200,
    hc:send-request(
        <hc:request method="GET"
        href="https://textgridlab.org/1.0/digilib/rest/IIIF/textgrid:{$uri};sid={environment-variable('TEXTGRID.SESSION')}/full/,2000/0/native.jpg"
        />
    )[2] => xs:base64Binary()
};


(:~
 : Endpoint to deliver a single plain text version of the
 : tei:text[@type = "transcription"] section a given document.
 :
 : Sample call to API: /content/3r671.txt
 :
 : @deprecated This function doesn't work properly and has been replaced with 
 : tapi:zip-text.
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/{$document}.txt")
    %output:method("text")
function tapi:text-rest($document as xs:string) as item()+ {
    $tapi:responseHeader200,
    tapi:text($document)
};


(:~
 : Returns the text of a given document as xs:string. Text nodes in tei:sic are
 : omitted since they are obviously typos or the like and are corrected in their
 : sibling tei:corr.
 :
 : @param $document The unprefixed TextGrid URI of a document, e.g. '3r671'
 : @return A string encompassing the whole text
 : @deprecated As of being buggy this function has been replaced by tapi:create-plain-text.
 :)
declare function tapi:text($document as xs:string) as xs:string {
    let $documentPath := $tapi:dataCollection || $document || ".xml"
    let $TEI := doc($documentPath)//tei:text[@type = "transcription"]
    let $text :=
        ($TEI//text()
            [not(parent::tei:sic)]
        ) => string-join() => replace("\n+", "") => replace("\s+", " ")
    return
        $text
};



(:~
 : Endpoint to deliver all plain texts in a zip container. This comes in handy
 : e.g. for applications doing text analysis.
 :
 : @return The response header as well as a xs:base64Binary (the ZIP file)
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/ahikar-plain-text.zip")
    %output:method("binary")
function tapi:text-rest() as item()+ {
    let $prepare := tapi:zip-text()
    return
        $tapi:responseHeader200,
        tapi:compress-to-zip()
};


(:~
 : Compressing all manuscripts available to ZIP.
 : 
 : @return the zipped files as xs:base64Binary
 :)
declare function tapi:compress-to-zip()
as xs:base64Binary* {
    compression:zip(xs:anyURI($tapi:baseCollection || "/txt/"), false())
};


(:~
 : Creates a plain text version of the transcription section of each Ahiqar XML.
 : This is stored to /db/apps/sade/textgrid/txt/.
 :
 : @return A string indicating the location where a plain text has been stored to
 :)
declare function tapi:zip-text() as xs:string+ {
    let $txtCollection := $tapi:baseCollection || "/txt/"
    let $collection := collection($tapi:dataCollection)
    let $check-text-collection :=
        if( xmldb:collection-available($txtCollection) )
        then true()
        else xmldb:create-collection($tapi:baseCollection, "txt")
    let $TEIs := $collection//tei:text[@type = ("transcription", "transliteration")][matches(descendant::text(), "[\w]")]
    return
        for $TEI in $TEIs
            let $baseUri := $TEI/base-uri()
            let $tgBaseUri := ($baseUri => tokenize("/"))[last()]
            let $type := $TEI/@type
            let $prefix :=
            switch ($type)
                case "transcription" return
                    switch ($TEI/@xml:lang)
                        case "karshuni" return "karshuni"
                        case "ara" return "arabic"
                        case "syc" return "syriac"
                        default return ()
                        
                (: although the transliteration may have another language than
                the transcription, the latter remains decisive for the prefix :)
                case "transliteration" return
                    (: transliterations are always encoded before transcriptions :)
                    switch ($TEI/following-sibling::tei:text[@type = "transcription"]/@xml:lang)
                        case "ara" return "arabic"
                        case "karshuni" return "karshuni"
                        case "syc" return "syc"
                        default return ()
                default return ()
                
            let $uri := $tgBaseUri => replace(".xml", concat("-", $type, ".txt"))
            let $text := tapi:create-plain-text($TEI)

            let $metadata := doc($baseUri => replace("/data/", "/meta/"))
            let $metaTitle := $metadata//tgmd:title => replace("[^a-zA-Z]", "_")
            return
                xmldb:store($txtCollection, $prefix || "-" || $metaTitle || "-" || $uri, $text, "text/plain")
};


(:~ 
 : Takes all relevant text nodes of a given TEI and transforms them in a 
 : normalized plain text.
 : 
 : The following nodes shouldn't be considered for the plain text creation:
 : * sic (wrong text)
 : * surplus (surplus text)
 : * supplied (supplied by modern editors)
 : * colophons
 : * glyphs
 : * unclear (text unclear)
 : * catchwords (they simply serve to bind the books correctly and reduplicate text)
 : * note (they have been added later by another scribe)
 : 
 : @param $TEI A TEI document
 : @return A string with all relevant text nodes.
 : 
 :)
declare function tapi:create-plain-text($TEI as node()) as xs:string {
    (($TEI//text()
        [not(parent::tei:sic)]
        [not(parent::tei:surplus)])
        [not(parent::tei:supplied)])
        [not(parent::tei:*[@type = "colophon"])]
        [not(parent::tei:g)]
        [not(parent::tei:unclear)]
        [not(parent::tei:catchwords)]
        [not(parent::tei:note)]
    => string-join()
    => replace("\p{P}", "")
    => replace("\n+", "")
    => replace("\s+", " ")
};


(:~ 
 : An API endpoint to get the plain text version of a resource.
 : 
 : It is possible to have either an edition or an XML file as input;
 : The function always selects the underlying XML file for txt creation.
 : 
 : Since we have different types of texts in Ahikar (depending on the manuscript's
 : language), we also introduced a query parameter to distinguish which text type
 : should serve as a base for creating the plain text.
 : The parameter defaults to 'transcription' which is the prevailing type.
 : 
 : Sample API calls:
 : 
 : * /textapi/ahikar/3r84h/3r176.txt
 : * /textapi/ahikar/3r84h/3r176.txt?type=transliteration
 : 
 : @param $collection The URI of the collection a resource is part of
 : @param $document The URI of an edition object or XML file that is to be serialized as plain text
 : @param $type A query parameter indicating which type of text should be serialized. Defaults to 'transcription'
 : @return The plain text of a given resource excluding the TEI header
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection}/{$document}.txt")
    %rest:query-param("type", "{$type}", "transcription")
    %output:method("text")
function tapi:txt($collection as xs:string, $document as xs:string,
$type) as item()+ {
    let $TEI := tapi:get-TEI-text($document, $type)
    return
        (
            $tapi:responseHeader200,
            tapi:create-plain-text($TEI)
        )
};


(:~
 : Returns the tei:text of a document as indicated by the @type parameter.
 : 
 : Due to the structure of the Ahikar project we can pass either an edition or
 : an XML file to the API endpoint for plain text creation.
 : This function determines the correct file which serves as a basis for the plain text.
 : 
 : @param $document The URI of a resource
 : @param $type Indicates the @type of tei:text to be processed
 : @return The tei:text element to be serialized as plain text
 :)
declare function tapi:get-TEI-text($document as xs:string, $type as xs:string)
as element(tei:text) {
    let $format := tapi:get-format($document)
    return
        if ($format = "text/xml") then
            doc($tapi:dataCollection || $document || ".xml")//tei:text[@type = $type]
        (: in this case the document is an edition which forces us to pick the
        text/xml file belonging to it :)
        else
            let $edition := doc($tapi:aggCollection || $document || ".xml")
            let $aggregated := for $agg in $edition//ore:aggregates/@rdf:resource return replace($agg, "textgrid:", "")
            let $xml :=
                for $agg in $aggregated return
                    if (tapi:get-format($agg) = "text/xml") then
                        $agg
                    else
                        ()
            return
                 doc($tapi:dataCollection || $xml || ".xml")//tei:text[@type = $type]
};

(:~
 : Returns the TextGrid metadata type of a resource.
 : 
 : @param $uri The URI of the resource
 : @return The resource's format as tgmd:format
 :)
declare function tapi:get-format($uri as xs:string) as xs:string {
    doc($tapi:metaCollection || $uri || ".xml")//tgmd:format
};


(:~
 : Returns the type of a resource in a SUB TextAPI compliant way.
 :
 : @param $format A string value of tgmd:format as used in the TextGrid metadata
 : @return A string indicating the format in a way compliant to the SUB TextAPI
 :)
declare %private function tapi:type($format as xs:string)
as xs:string {
    switch ($format)
        case "text/tg.aggregation+xml" return "collection"
        case "text/tg.edition+tg.aggregation+xml" return "manifest"
        default return "manifest"
};

declare function tapi:add-IDs($tei as element(tei:TEI)) as element(tei:TEI) {
    tapi:add-IDs-recursion($tei)
};

declare function tapi:add-IDs-recursion($nodes as node()*) as node()* {
    util:log-system-out($nodes),
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
                tapi:add-IDs-recursion($node/node())
            }
};
