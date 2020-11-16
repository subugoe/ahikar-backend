xquery version "3.1";

(:~
 : This module provides the REST interface for Ahiqar's AnnotationAPI.
 :
 : @author Michelle Weidling
 : @version 1.8.1
 : @since 1.7.0
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/
 : @see https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/text-api-specs/
 : :)

module namespace anno-rest="http://ahikar.sub.uni-goettingen.de/ns/annotations/rest";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";

import module namespace anno="http://ahikar.sub.uni-goettingen.de/ns/annotations" at "annotations.xqm";
import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace requestr="http://exquery.org/ns/request";
import module namespace rest="http://exquery.org/ns/restxq";

declare variable $anno-rest:server :=
    if(try {
    requestr:hostname() = "existdb"
} catch * {
    true()
})
    then doc("../expath-pkg.xml")/*/@name => replace("/$", "")
    else "http://localhost:8094/exist/restxq";

(:~
 : Returns annotation information about a single collection. Although this works for all collections,
 : it has mainly been designed for Ahikar's main collection, 3r132.
 : 
 : For retrieving annotation information about other collections cf. the endpoint
 : /annotations/ahikar/{$collection}/{$document}/annotationCollection.json
 : 
 : @param $collection The URI of the collection, e.g. '3r132'
 : @return An Annotation Collecion for the given collection
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/annotations/ahikar/{$collection}/annotationCollection.json")
    %output:method("json")
function anno-rest:collection-rest($collection as xs:string) {
    if (anno:are-resources-available($collection)) then
        ($commons:responseHeader200,
        anno:make-annotationCollection($collection, (), $anno-rest:server))
    else
        anno-rest:get-404-header($collection)
};

(:~
 : Returns the Annotation Page of a given Collection Object according to W3C.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/annotationPage.json")
    %output:method("json")
function anno-rest:annotationPage-for-collection-rest($collection as xs:string, 
$document as xs:string) {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationPage($collection, $document, $anno-rest:server))
        
    else
        anno-rest:get-404-header(($collection, $document))
};


(:~
 : Returns the Annotation Collection of a given Collection or Manifest Object according to W3C.
 : 
 : The Collection Object given by $collection mainly serves for identification and compliance
 : with the TextAPI.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @return An Annotation Collecion for the given Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/annotationCollection.json")
    %output:method("json")
function anno-rest:manifest-rest($collection as xs:string, 
$document as xs:string) {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationCollection($collection, $document, $anno-rest:server))
        
    else
        anno-rest:get-404-header(($collection, $document))
};


(:~
 : Returns the Annotation Collection of a given Collection or Manifest Object according to W3C.
 : 
 : The Collection Object given by $collection mainly serves for identification and compliance
 : with the TextAPI.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-collection
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @return An Annotation Collection for the given Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/{$page}/annotationCollection.json")
    %output:method("json")
function anno-rest:annotationCollection-for-manifest-rest($collection as xs:string, 
$document as xs:string, $page as xs:string) {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationCollection-for-manifest($collection, $document, $page, $anno-rest:server))
        
    else
        anno-rest:get-404-header(($collection, $document))
};

(:~
 : Returns the Annotation Page of a given Collection or Manifest Object according to W3C.
 : 
 : The Collection Object given by $collection mainly serves for identification and compliance
 : with the TextAPI.
 : 
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://www.w3.org/TR/annotation-model/#annotation-page
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#collection-object
 : @see https://subugoe.pages.gwdg.de/emo/text-api/page/specs/#manifest-object
 : 
 : @param $collection The URI of the Collection Object
 : @param $document The URI of an aggregated Collection or Manifest Object
 : @param $page The page within an item, i.e. a tei:pb/@n within a TEI resource
 : @return An Annotation Page for the given Collection or Manifest Object
 :)
declare
    %rest:GET
    %rest:HEAD
    %rest:path("/api/annotations/ahikar/{$collection}/{$document}/{$page}/annotationPage.json")
    %output:method("json")
function anno-rest:annotationPage-for-manifest-rest($collection as xs:string, 
    $document as xs:string,
    $page as xs:string)
as element()+ {
    if (anno:are-resources-available(($collection, $document))) then
        ($commons:responseHeader200,
        anno:make-annotationPage-for-manifest($collection, $document, $page, $anno-rest:server))
        
    else
        anno-rest:get-404-header(($collection, $document))
};

(:~
 : Creates a HTTP 404 header containing information about missing resources.
 : This function is called whenever an API call is made but at least one of the
 : requested resources isn't available.
 : 
 : @param $resources The URIs of resource's requested in an API call
 : @return The response header
 :)
(:  ## tested ## :)
declare function anno-rest:get-404-header($resources as xs:string+) {
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" 
            status="404"
            message="One of the following requested resources couldn't be found: {string-join($resources, ", ")}">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>
};