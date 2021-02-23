xquery version "3.1";

module namespace ct="http://ahikar.sub.uni-goettingen.de/ns/commons-tests/credentials";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../modules/commons.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

(:~
 : Depending on the order of test execution, a session id is already available. In this case the
 : test provided here will not cover the major part of the function, but they are tested by the
 : preceding function call(s).
 : WARNING: failing test here will expose the result, which might be a valid session id.
:)
declare
    %test:assertXPath("string-length($result) gt 5")
    %test:assertXPath("matches($result, '[a-zA-Z0-9]+')")
    %test:assertXPath("util:binary-doc-available('/db/sid.txt')")
function ct:get-textgrid-session-id()
as xs:string {
    commons:get-textgrid-session-id()
};
