xquery version "3.1";

module namespace st="http://ahikar.sub.uni-goettingen.de/ns/search/tests";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace search="http://ahikar.sub.uni-goettingen.de/ns/search" at "../modules/search.xqm";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare
    %test:assertEquals("Beispieldatei zum Testen", 3, "true")
function st:search() {
    let $json := map {
      "query": map {
        "simple_query_string": map {
          "query": "ܘܐ*"  }
      },
      "from": 0,
      "size": 3,
      "kwicsize": 20
    }

    return (
        search:perform($json)("hits")("hits")?1("label"),
        search:perform($json)("hits")("hits")?* => count(),
        search:perform($json)("hits")("total")("value") gt 60
    )
};
