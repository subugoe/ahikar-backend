xquery version "3.1";

module namespace import="http://ahikar.sub.uni-goettingen.de/ns/import";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";
import module namespace rest="http://exquery.org/ns/restxq";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare
    %rest:GET
    %rest:HEAD
    %rest:path("/import-data")
    %rest:query-param("token", "{$token}")
    %output:method("json")
function import:main($token) {
    if( $token ne environment-variable("APP_DEPLOY_TOKEN" )) then
        error(QName("error://1", "deploy"), "Deploy token incorrect.")
    else
        util:eval(xs:anyURI($commons:appHome || "import-data.xq"))
};
