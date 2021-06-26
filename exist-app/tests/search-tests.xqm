xquery version "3.1";

module namespace st="http://ahikar.sub.uni-goettingen.de/ns/search/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace search="http://ahikar.sub.uni-goettingen.de/ns/search" at "../modules/search.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:assertEquals("The Story and Proverbs of Ahiqar the Wise", 2)
function st:search() {
    let $body :=
        '{
          "query": {
            "simple_query_string": {
              "query": "Erfa*"  }
          },
          "from": 1,
          "size": 1,
          "kwicsize": 20
        }' => util:base64-encode()
    
    return
        (search:main($body)("hits")("hits")?*("title"),
        search:main($body)("hits")("total")("value"))
};
