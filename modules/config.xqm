xquery version "3.1";
(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)

module namespace config="https://sade.textgrid.de/ns/config";

declare namespace cf="https://sade.textgrid.de/ns/configfile";
declare namespace expath="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";

(:
 : Determine the application root collection from the current module load path.
:)
declare variable $config:app-root :=
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring-after($rawPath, "xmldb:exist://embedded-eXist-server")
            else
                substring-after($rawPath, "xmldb:exist://")
        else
            $rawPath
    let $path := substring-before($modulePath, "/modules")
    return if (starts-with($path, "null")) then substring-after($path, "null") else $path;

declare variable $config:data-root := $config:app-root || "/" || config:get("project-id");
declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;
declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

declare variable $config:file := doc(concat($config:app-root, "/config.xml"));

(:~
 : A function to query the global SADE config.
 : @param $key – the name of the parameter to query for
 :  :)
declare function config:get($key as xs:string){
    $config:file/cf:config/cf:param[@key = $key]/node()
};

(:~
 : A function to query the SADE config for module specific parameter.
 : @param $key – the name of the parameter to query for
 : @param $module-key – the name of the module
 :  :)
declare function config:get($key as xs:string, $module-key as xs:string?) {
    let $base := $config:file/cf:config/cf:module[@key = $module-key]/cf:param[@key = $key]
    let $elements := $base/*
    return if($elements) then $elements else $base/node()
};

(:~
 : Tests for availability of a module or parameter in the cofig file
 : @param $key – the key
 : @return xs:boolean
 :   :)
declare function config:key-available($key as xs:string) as xs:boolean {
    $config:file/cf:config//*/string(@key) = $key
};

(:~
 : A function to query the app repo config.
 : @param $key – the name of the element to query for
 :  :)
declare function config:repoget($key as xs:string)
as xs:string? {
    $config:repo-descriptor//*[local-name() = $key] ! string(.)
};
