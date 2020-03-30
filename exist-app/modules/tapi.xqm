xquery version "3.1";

(:~
 : This module provides the TextAPI for Ahikar.
 :
 : @author Mathias Göbel
 : @version 0.0.1
 : @since 0.0.0
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

declare variable $tapi:version := "0.1.0";
declare variable $tapi:server := if(requestr:hostname() = "existdb") then doc("../expath-pkg.xml")/*/@name => replace("/$", "") else "http://localhost:8094/exist/restxq";
declare variable $tapi:baseCollection := "/db/apps/sade/textgrid";

declare variable $tapi:responseHeader200 :=
    <rest:response>
        <http:response xmlns:http="http://expath.org/ns/http-client" status="200">
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>;

(:~
 : Shows information on the currently installed application
 :   :)
declare
    %rest:GET
    %rest:path("/api/info")
    %output:method("json")
function tapi:info-rest()
as item()+ {
    $tapi:responseHeader200,
    tapi:info()
};

declare function tapi:info()
as item()+ {
    <descriptors>
        <request>
            <scheme>{ requestr:scheme() }</scheme>
            <hostname>{ requestr:hostname() }</hostname>
            <uri>{ requestr:uri() }</uri>
        </request>
        {doc("../expath-pkg.xml"),
        doc("../repo.xml")}
    </descriptors>
};

declare
    %rest:GET
    %rest:path("/textapi/ahikar/{$collection}/collection.json")
    %output:method("json")
function tapi:collection-rest($collection){
    $tapi:responseHeader200,
    tapi:collection($collection)
};

(:~
 : Main collection for the project.
 : should be textgrid:3r132
 :   :)
declare function tapi:collection($collection)
as item()+ {
    let $aggregation := doc("/db/apps/sade/textgrid/agg/" || $collection || ".xml")
    let $meta := //tgmd:textgridUri[starts-with(., "textgrid:" || $collection)]/root()
    let $sequence :=
        for $i in $aggregation//*:aggregates/string(@*:resource)
        let $metaObject := //tgmd:textgridUri[starts-with(., $i)]/root()
        return
            <sequence>
                <id>{$tapi:server}/api/textapi/ahikar/{$collection}/{substring-after($i, ":")}/manifest.json</id>
                <type>{
                if($collection = "3r84g")
                then
                    "manifest"
                else
                    ($metaObject//tgmd:format)[1] => string() => tapi:type()
                }</type>
            </sequence>
    return
    <object>
        <textapi>{$tapi:version}</textapi>
        <title>
            <title>The Story and Proverbs of Ahikar the Wise</title>
            <type>{$meta//tgmd:format => string() => tapi:type()}</type>
        </title>
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
        <description>Main collection for the Ahikar project. Funded by DFG, 2019-2020. University of Göttingen</description>
        {$sequence}
    </object>
};

declare
    %rest:GET
    %rest:path("/textapi/ahikar/{$collection}/{$document}/manifest.json")
    %output:method("json")
function tapi:manifest-rest($collection, $document) {
    $tapi:responseHeader200,
    tapi:manifest($collection, $document)
};

declare function tapi:manifest($collection, $document) {
    let $aggNode := doc("/db/apps/sade/textgrid/agg/" || $document || ".xml")
    let $metaNode := doc("/db/apps/sade/textgrid/meta/" || $document || ".xml")
    let $documentUri := $aggNode//ore:aggregates[1]/@rdf:resource => substring-after(":")
    let $documentNode := doc("/db/apps/sade/textgrid/data/" || $documentUri || ".xml")
    let $sequence :=
        for $page in $documentNode//tei:pb/string(@n)
        let $uri := "/api/textapi/ahikar/" || $collection || "/" || $document || "-" ||  $page || "/latest/item.json"
        return
            <sequence>
                <id>{$tapi:server}{$uri}</id>
                <type>item</type>
            </sequence>
    return
    <object>
        <textapi>{$tapi:version}</textapi>
        <label>{string($metaNode//tgmd:title)}</label>
        <license>CC0-1.0</license>
        {$sequence}
    </object>
};

declare
    %rest:GET
    %rest:path("/textapi/ahikar/{$collection}/{$document}-{$page}/latest/item.json")
    %output:method("json")
function tapi:item-rest($collection, $document, $page) {
    $tapi:responseHeader200,
    tapi:item($collection, $document, $page)
};

declare function tapi:item($collection, $document, $page) {
    let $aggNode := doc("/db/apps/sade/textgrid/agg/" || $document || ".xml")
    let $teiUri :=
        if($aggNode)
        then $aggNode//ore:aggregates[1]/@rdf:resource => substring-after(":")
        else $document
    let $image := doc("/db/apps/sade/textgrid/data/" || $teiUri || ".xml")//tei:pb[@n = $page]/@facs => substring-after("textgrid:")
    return
    <object>
        <textapi>{$tapi:version}</textapi>
        <title>The Story and Proverbs of Ahikar the Wise</title>
        <type>page</type>
        <n>{$page}</n>
        <content>{$tapi:server}/api/content/{$teiUri}-{$page}.html</content>
        <content-type>application/xhtml+xml</content-type>
        <language>syr</language>
        <image>
            <id>{$tapi:server}/api/images/{$image}</id>
        </image>
    </object>
};

declare
    %rest:GET
    %rest:path("/content/{$document}-{$page}.html")
    %output:method("xml")
    %output:indent("no")
function tapi:content-rest($document, $page) {
    $tapi:responseHeader200,
    tapi:content($document, $page)
};

declare function tapi:content($document, $page) {
    let $documentPath := "/db/apps/sade/textgrid/data/" || $document || ".xml"
    let $TEI :=
        if($page)
        then
            let $node := doc($documentPath),
                $start-node := $node//tei:pb[@n = $page],
                $end-node :=
                    let $followingPb := $node//tei:pb[@n = $page]/following::tei:pb[1]
                    return
                        if($followingPb)
                        then $followingPb
                        else $node//tei:pb[@n = $page]/following::tei:ab[last()],
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
    let $stylesheet := doc( "/db/apps/sade_assets/TEI-Stylesheets/html5/html5.xsl")
    let $transform := transform:transform($TEI, $stylesheet, ())/xhtml:body//xhtml:div[@class="tei_body"]
    return
        <div>
            {$transform}
        </div>
};

declare
    %rest:GET
    %rest:path("/images/{$uri}")
    %rest:produces("image/jpeg")
    %output:method("binary")
function tapi:content-rest($uri) {
    $tapi:responseHeader200,
    hc:send-request(
        <hc:request method="GET"
        href="https://textgridlab.org/1.0/tgcrud/rest/textgrid:{$uri}/data?sessionId={environment-variable('TEXTGRID.SESSION')}"
    />
    )[2] => xs:base64Binary()
};


(:~
 : Endpoint to deliver a single plain text.
 : @param $document a vaild textgrid URI
 :  :)
declare
    %rest:GET
    %rest:path("/content/{$document}.txt")
    %output:method("text")
function tapi:text-rest($document) {
    $tapi:responseHeader200,
    tapi:text($document)
};

declare function tapi:text($document) {
    let $documentPath := "/db/apps/sade/textgrid/data/" || $document || ".xml"
    let $TEI := doc($documentPath)//tei:text[@type="transcription"]
    let $text :=
        ($TEI//text()
            [not(parent::tei:sic)]
        ) => string-join() => replace("\n+", "") => replace("\s+", " ")
    return
        $text
};

(:~
 : Endpoint to deliver all plain texts in zip container.
 :  :)
declare
    %rest:GET
    %rest:path("/content/ahikar-plain-text.zip")
    %output:method("binary")
function tapi:text-rest($document) {
    let $prepare := tapi:zip-text()
    return
        $tapi:responseHeader200,
        compression:zip(xs:anyURI($tapi:baseCollection || "/txt/"), false())
};

declare function tapi:zip-text() {
    let $txtCollection := $tapi:baseCollection || "/txt/"
    let $collection := collection($tapi:baseCollection || "/data/")
    let $check-text-collection :=
        if( xmldb:collection-available($txtCollection) )
        then true()
        else xmldb:create-collection($tapi:baseCollection, "txt")
    let $TEIs := $collection//tei:text[@type="transcription"]
    return
        for $TEI in $TEIs
        let $baseUri := $TEI/base-uri()
        let $tgBaseUri := ($baseUri => tokenize("/"))[last()]
        let $uri := $tgBaseUri => replace(".xml", "-transcription.txt")
        let $text :=
            (($TEI//text()
                [not(parent::tei:sic)]
                [not(parent::tei:surplus)])
                [not(parent::tei:supplied)])
                [not(parent::tei:*[@type="colophon"])]
                [not(parent::tei:g)]
                [not(parent::tei:unclear)]
                [not(parent::tei:catchwords)]
            => string-join()
            => replace("\p{P}", "")
            => replace("\n+", "")
            => replace("\s+", " ")

        let $metadata := doc($baseUri => replace("/data/", "/meta/"))
        let $metaTitle := $metadata//tgmd:title => replace("[^a-zA-Z]", "_")
        return
            xmldb:store($txtCollection, $metaTitle || "-" || $uri, $text, "text/plain")
};

(:~
 : redeploy application to db
 :  :)
declare
  %rest:GET
  %rest:path("/deploy")
  %rest:query-param("token", "{$token}")
function tapi:redeploy($token) {
  if( $token ne environment-variable("APP_DEPLOY_TOKEN" ))
  then error(QName("error://1", "deploy"), "deploy token incorrect.")
  else
    let $pkgName := environment-variable("APP_NAME")
    let $name := 'https://ci.de.dariah.eu/exist-repo/find.zip?name=' || encode-for-uri($pkgName)
    let $request :=
        <hc:request
          method="GET"
          href="{$name}" />
    let $package := hc:send-request($request)
    let $storeToDb := xmldb:store("/db", "ahikar-deployment.xar", $package[2], "application/zip")
    let $remove := repo:remove($pkgName)
    let $install := repo:install-and-deploy-from-db($storeToDb)
    return
        $install
};

declare %private function tapi:type($format as xs:string)
as xs:string {
    switch ($format)
        case "text/tg.aggregation+xml" return "collection"
        case "text/tg.edition+tg.aggregation+xml" return "manifest"
        default return "manifest"
};
