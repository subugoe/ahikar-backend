xquery version "3.1";

(:~
 : This module provides the TextAPI for Ahiqar. For an extensive explanation of
 : the whole Ahiqar specific implementation of the generic TextAPI see the link
 : to the API docs.
 :
 : @author Mathias Göbel
 : @author Michelle Weidling
 : @since 0.0.0
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/
 : :)

module namespace tapi="http://ahikar.sub.uni-goettingen.de/ns/tapi";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace tapi-coll="http://ahikar.sub.uni-goettingen.de/ns/tapi/collection" at "tapi-collection.xqm";
import module namespace tapi-item="http://ahikar.sub.uni-goettingen.de/ns/tapi/item" at "tapi-item.xqm";
import module namespace tapi-mani="http://ahikar.sub.uni-goettingen.de/ns/tapi/manifest" at "tapi-manifest.xqm";
import module namespace tapi-txt="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt" at "tapi-txt.xqm";
import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";
import module namespace tei2html="http://ahikar.sub.uni-goettingen.de/ns/tei2html" at "tei2html.xqm";
import module namespace tapi-html="http://ahikar.sub.uni-goettingen.de/ns/tapi/html" at "tapi-html.xqm";

declare variable $tapi:server :=
    if(requestr:hostname() = "existdb") then
        $commons:expath-pkg/*/@name => replace("/$", "")
    else
        "http://localhost:8094/exist/restxq";

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
function tapi:endpoint-info()
as item()+ {
    $commons:responseHeader200,
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
            tapi:remove-whitespaces(doc($commons:appHome || "/expath-pkg.xml")),
            tapi:remove-whitespaces(doc($commons:appHome || "/repo.xml"))
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
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @param $collection-type The collection type. Can either be `syriac` or `arabic-karshuni`
 : @return A collection object as JSON
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection-type}/collection.json")
    %output:method("json")
function tapi:endpoint-collection($collection-type as xs:string)
as item()+ {
    $commons:responseHeader200,
    tapi-coll:get-json($collection-type, $tapi:server)
};


(:~
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection-type}/{$manifest-uri}/manifest.json")
    %output:method("json")
function tapi:endpoint-manifest($collection-type as xs:string,
    $manifest-uri as xs:string)
as item()+ {
    $commons:responseHeader200,
    tapi-mani:get-json($collection-type, $manifest-uri, $tapi:server)
};


(:~
 : Returns information about a given page in a document. This is mainly compliant
 : with the SUB TextAPI, but has the following additions:
 :  * the division number, 'n', is mandatory
 :  * 'image' is mandatory since every page has a facsimile
 :
 : Sample call to API: /api/textapi/ahikar/syriac/3r1pq-147a/latest/item.json
 :
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#item
 : @param $collection-type The collection type. Can either be `syriac` or `arabic-karshuni`
 : @param $manifest-uri The unprefixed TextGrid URI of a document, e.g. '3r1pq'
 : @param $page A page number as encoded in a tei:pb/@n, e.g. '147a'
 : @return Information about a page
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/textapi/ahikar/{$collection-type}/{$manifest-uri}-{$page}/latest/item.json")
    %output:method("json")
function tapi:endpoint-item($collection-type as xs:string,
    $manifest-uri as xs:string,
    $page as xs:string)
as item()+ {
    $commons:responseHeader200,
    tapi-item:get-json($collection-type, $manifest-uri, $page, $tapi:server)
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
 : @param $tei-xml-uri The unprefixed TextGrid URI of a TEI/XML, e.g. '3rbmb'
 : @param $page The page to be rendered. This has to be the string value of a tei:pb/@n in the given document, e.g. '1a'
 : @return A response header as well as the rendered HTML page
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/{$html-type}/{$tei-xml-uri}-{$page}.html")
    %output:method("xml")
    %output:indent("no")
function tapi:endpoint-html($tei-xml-uri as xs:string,
    $html-type as xs:string,
    $page as xs:string)
as item()+ {
    $commons:responseHeader200,
    tapi-html:get-html($tei-xml-uri, $page)
};

(:~
 : Returns an image belonging to a given URI. This function doesn't work locally
 : unless you have all necessary login information filled in at ahikar.env.
 : 
 : Since these images of the Ahikar project aren't publicly available, this
 : function cannot be tested by unit tests.
 :
 : @param $availability-flag either `public` or `restricted`
 : @param $uri The unprefixed TextGrid URI of an image, e.g. '3r1pr'
 : @return The image as binary
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/images/{$availability-flag}/{$uri}")
    %rest:produces("image/jpeg")
    %output:method("binary")
function tapi:endpoint-restricted-image($availability-flag as xs:string,
    $uri as xs:string)
as item()+ {
    local:make-image-request($availability-flag, $uri, "")
};

(:~
 : Returns an image section belonging to a given URI as defined by the $image-section
 : paramater.
 : This function doesn't work locally unless you have all necessary login
 : information filled in at ahikar.env.
 : 
 : Since the images of the Ahikar project aren't publicly available, this
 : function cannot be tested by unit tests.
 :
 : @param $availability-flag either `public` or `restricted`
 : @param $uri The unprefixed TextGrid URI of an image, e.g. '3r1pr'
 : @param $image-section Indicates the image section in percentage to be retured as defined by
 : the IIIF Image API
 : @return The image as binary
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/images/{$availability-flag}/{$uri}/{$image-section}")
    %rest:produces("image/jpeg")
    %output:method("binary")
function tapi:endpoint-image($availability-flag as xs:string,
    $uri as xs:string,
    $image-section as xs:string)
as item()+ {
    local:make-image-request($availability-flag, $uri, $image-section)
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
    %rest:path("/content/{$document-uri}.txt")
    %rest:query-param("type", "{$type}", "transcription")
    %output:method("text")
function tapi:endpoint-txt($document-uri as xs:string,
    $type)
as item()+ {
    let $pseudo-chunk :=
        element tei:TEI {
            tapi-txt:get-TEI-text($document-uri, $type)
        }
    return
        ( 
            $commons:responseHeader200,
            tapi-txt:make-plain-text-from-chunk($pseudo-chunk)
        )
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
function tapi:endpoint-zip() as item()+ {
    let $prepare := tapi-txt:main()
    return
        $commons:responseHeader200,
        tapi-txt:compress-to-zip()
};


declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/{$font}.otf")
    %output:method("text")
    %output:media-type("font/otf")
function tapi:endpoint-fonts($font as xs:string) as item()+ {
    $commons:responseHeader200,
    util:binary-doc(concat("/db/data/resources/css/", $font, ".css"))
    => util:base64-decode()
};

declare
    %rest:GET
    %rest:HEAD
    %rest:path("/content/ahikar.css")
    %output:method("text")
    %output:media-type("text/css")
function tapi:endpoint-css() as item()+ {
    $commons:responseHeader200,
    util:binary-doc("/db/data/resources/css/ahikar.css")
    => util:base64-decode()
};


(:~
 : Requests image data depending on the parameters passed.
 : 
 : Sample calls processed by this function include:
 : * /image/public/12345
 : * /image/restricted/6789/50.03,0.48,49.83,100.00
 : 
 :)
declare function local:make-image-request($availability-flag as xs:string,
    $uri as xs:string,
    $image-section as xs:string?)
as item()+ {
    if ($availability-flag = ("public", "restricted")) then
        let $sessionID :=
            if ($availability-flag = "restricted") then
                ";sid=" || commons:get-textgrid-session-id()
            else
                (: as soon as the public images have been published in the
                TextGrid Repository, we won't need a session ID for them. In
                the meantime the session ID is still necessary. :)
(:                "":)
                ";sid=" || commons:get-textgrid-session-id()
        let $section :=
            if ($image-section) then
                "/pct:" || $image-section
            else
                "/full"
        return
            (
                $commons:responseHeader200,
                try {
                    hc:send-request(
                        <hc:request method="GET"
                        href="https://textgridlab.org/1.0/digilib/rest/IIIF/textgrid:{$uri}{$sessionID}{$section}/,2000/0/native.jpg"
                        />
                    )[2] => xs:base64Binary()
                } catch * {
                    error(QName("http://ahikar.sub.uni-goettingen.de/ns/tapi", "TAPI01"), "The requested image with the URI " || $uri || " could not be fetched.")
                }
            )
    else
        <rest:response>
            <http:response xmlns:http="http://expath.org/ns/http-client" status="404">
                <http:header name="Access-Control-Allow-Origin" value="*"/>
            </http:response>
        </rest:response>
};
