xquery version "3.1";

(:~
 : This module is responsible for (re)deploying the application while the database 
 : is running.
 :
 : @author Michelle Weidling
 : @author Mathias Göbel
 : @version 0.1.0
 : @since 0.4.0
 :)

module namespace deploy="http://ahikar.sub.uni-goettingen.de/ns/deploy";

import module namespace rest="http://exquery.org/ns/restxq";

(:~
 : Redeploy the Ahikar application to the DB.
 : 
 : This function is needed to deploy a newer version of the app to the running 
 : docker environment we use for deployment. It is called by the CI.
 : 
 : It
 : * downloads the newest package from the repo
 : * stores it to the db
 : * installs and deploys from a db resource (this will internally uninstall the
 : application at first and install the new version afterwards)
 : 
 : @param $token A CI token
 : @return element() <status result="ok"/> if deployment was ok
 :  :)
declare
  %rest:GET
  %rest:HEAD
  %rest:path("/deploy")
  %rest:query-param("token", "{$token}")
function deploy:redeploy($token)
as element()? {
  if(not($token = environment-variable("APP_DEPLOY_TOKEN" )))
    then error(QName("error://1", "DEPLOY01"), "deploy token incorrect.")
  else
    let $pkgName := environment-variable("APP_NAME")
    let $name := 'https://ci.de.dariah.eu/exist-repo/find.zip?name=' || encode-for-uri($pkgName)
    let $request :=
        <hc:request
          method="GET"
          href="{$name}" />
    let $package := 
        try {
            hc:send-request($request)
        } catch * {
            error(QName("http://ahikar.sub.uni-goettingen.de/ns/deploy", "DEPLOY1"), "Package " || $pkgName || " could not be fetched.")
        }
    let $storeToDb := xmldb:store("/db", "ahikar-deployment.xar", $package[2], "application/zip")
    let $remove := repo:remove($pkgName)
    let $install := repo:install-and-deploy-from-db($storeToDb)
    return
        $install
};



(:~
 : Redeploy a certain version of the Ahiqar application to the DB.
 : This is particularly important for the correct deployment on ahikar-test.
 : 
 : This function is needed to deploy a given version of the app to the running 
 : docker environment we use for deployment. It is called by the CI.
 : 
 : It
 : * downloads the package version given from the repo
 : * stores it to the db
 : * installs and deploys from a db resource (this will internally uninstall the
 : application at first and install the new version afterwards)
 : 
 : @param $version The version to be deployed. Has to satisfy the Semantiv Versioning format.
 : @param $token A CI token
 : @return element() <status result="ok"/> if deployment was ok
 :)
declare
  %rest:GET
  %rest:HEAD
  %rest:path("/deploy/{$version}")
  %rest:query-param("token", "{$token}")
function deploy:redeploy($version as xs:string,
    $token)
as item()+ {
    if(not($token = environment-variable("APP_DEPLOY_TOKEN" ))) then
        error(QName("error://1", "DEPLOY01"), "Deploy token incorrect.")
    else if (not(matches($version, "\d+\.\d+\.\d+"))) then
        error(QName("error://1", "DEPLOY02"), $version || " is not a version number according to Semantic Versioning.")
    else
        let $pkgName := environment-variable("APP_NAME")
        let $pkg := local:determine-package($pkgName, $version)
        let $url := "https://ci.de.dariah.eu/exist-repo/public/" || $pkg
        let $request :=
            <hc:request
              method="GET"
              href="{$url}" />
        let $package := hc:send-request($request)
        let $storeToDb := xmldb:store("/db", "ahikar-deployment.xar", $package[2], "application/zip")
        return
            ( 
                repo:remove($pkgName),
                repo:install-and-deploy-from-db($storeToDb)
            )
};

declare function local:determine-package($pkgName as xs:string,
    $version as xs:string)
as xs:string {
    let $pkg :=
        switch ($pkgName)
            case "https://ahikar-test.sub.uni-goettingen.de/" return "ahikar-test-"
            case "https://ahikar-dev.sub.uni-goettingen.de/" return "ahikar-dev-"
            default return "ahikar-"
    return
        $pkg || $version || ".xar"
};
