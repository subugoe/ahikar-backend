xquery version "3.1";

(:~
 : Generates a menu based on the published objects, like the navigator does in
 : the Lab.
 : @author Mathias Göbel
 :)

module namespace tgmenu="https://sade.textgrid.de/ns/tgmenu";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="https://sade.textgrid.de/ns/config" at "../config.xqm";

declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace ore="http://www.openarchives.org/ore/terms/";

declare function tgmenu:template($node as node(), $model as map(*)) {

let $metacollection := collection( $config:data-root || "/meta" )
let $uris := $metacollection//tgmd:textgridUri/string()
return
  if($uris = ())
  then error(
      QName("https://sade.textgrid.de/ns/error", "MENU01"),
      "There is no data available. Please publish items at first.")
  else (: continue :)
let $aggcollection := collection( $config:data-root || "/agg" )
let $aggregates := $aggcollection//ore:aggregates/string(@rdf:resource)

return
    tgmenu:list($uris[not(.=$aggregates)], $metacollection, $aggcollection)
};

declare function tgmenu:list($uris as xs:string*, $metacollection, $aggcollection) as element( ul ) {
<ul class="nav-textgrid">
{for $uri in $uris
    let $escaped-uri := $uri => xmldb:encode-uri() => xs:string()
    let $meta := $metacollection//tgmd:object[tgmd:generic/tgmd:generated/tgmd:textgridUri = $uri]
    let $title := $meta//tgmd:title/string()
    let $format := $meta//tgmd:format/string()
 where $title != ""
 return
     <li class="{replace($format, "[^a-z]", "")}" title="{$format}">{
         if($format = "text/xml")
         then
            (element a {
             attribute href {"./" || $escaped-uri},
             $title
         },
         "&#160;",
         element a {
             attribute href {"./raw.html?id="||$escaped-uri},
             <i class="fas fa-file-code" aria-hidden="true"></i>
         })
         else $title}{
        if( contains($format, "tg.aggregation") )
        then (
            let $uris := $aggcollection//rdf:Description[@rdf:about = $uri]/ore:aggregates/string(@rdf:resource)
            return
                tgmenu:list($uris, $metacollection, $aggcollection))
        else ()
     }</li>
}
</ul>

};


declare function tgmenu:files-total($node as node(), $model as map(*)) {
    let $no-of-items := count(collection( $config:data-root || "/meta" )) - 1
    return
        <span>Total numbers of items stored in SADE: {$no-of-items}</span>
};
