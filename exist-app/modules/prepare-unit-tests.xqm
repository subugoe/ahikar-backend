xquery version "3.1";

module namespace pu="http://ahikar.sub.uni-goettingen.de/ns/prepare-unit-tests";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "/db/apps/ahikar/modules/commons.xqm";
import module namespace dbt="http://ahikar.sub.uni-goettingen.de/ns/database-triggers" at "/db/apps/ahikar/triggers/trigger.xql";
import module namespace rest="http://exquery.org/ns/restxq";

declare
    %rest:GET
    %rest:HEAD
    %rest:path("/prepare-unit-tests")
    %rest:query-param("token", "{$token}")
function pu:main($token)
as item()+ {
    if( $token ne environment-variable("APP_DEPLOY_TOKEN" )) then
        error(QName("error://1", "deploy"), "Deploy token incorrect.")
    else
        (
            dbt:prepare-collections-for-triggers(),
            let $uris :=
                for $uri in xmldb:get-child-resources($commons:data)[starts-with(., "sample_")] return
                    $commons:data || $uri
            
            for $uri in $uris return
                dbt:process-triggers($uri)
        )
};
