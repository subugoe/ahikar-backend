xquery version "3.1";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if (starts-with($exist:path, "/openapi/")) then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward
      url="/openapi/{ $exist:path => substring-after("/openapi/") => replace("json", "xq") }"
      method="get">
      <add-parameter name="target" value="{ substring-after($exist:root, "://") || $exist:controller }"/>
      <add-parameter name="register" value="false"/>
    </forward>
  </dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
