xquery version "3.1";

(:~
 : This module is responsible for (re)deploying the application while the database 
 : is running.
 :
 : @author Michelle Weidling
 : @author Mathias Göbel
 : @version 0.1.0
 : @since 0.5.0
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
  %rest:query-param("version", "{$version}")
function deploy:redeploy($token, $version)
as element()? {
  if(not($token = environment-variable("APP_DEPLOY_TOKEN" )))
    then error(QName("http://ahikar.sub.uni-goettingen.de/ns/deploy", "DEPLOY01"), "deploy token incorrect.")
  else
    let $pkgName := environment-variable("APP_NAME")
    let $name :=
        if($version) then
          'https://ci.de.dariah.eu/exist-repo/find?name=' || encode-for-uri($pkgName) || '&amp;version=' || $version
        else
          'https://ci.de.dariah.eu/exist-repo/find?name=' || encode-for-uri($pkgName) || '&amp;processor=' || system:get-version()
    let $request :=
        <hc:request
          method="GET"
          href="{$name}" />
    let $package := 
        try {
            hc:send-request($request)
        } catch * {
            error(QName("http://ahikar.sub.uni-goettingen.de/ns/deploy", "DEPLOY2"), "Package " || $pkgName || " could not be fetched.")
        }
    let $storeToDb := xmldb:store("/db", "ahikar-deployment.xar", $package[2], "application/zip")
    let $remove := repo:remove($pkgName)
    let $install := repo:install-and-deploy-from-db($storeToDb)
    return
        $install
};
