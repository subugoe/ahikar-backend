xquery version "3.1";

(:~
 : This module provides some test end points that simply return HTTP headers
 : with different status codes.
 :
 : @author Michelle Weidling
 : :)

module namespace head="http://ahikar.sub.uni-goettingen.de/ns/http-headers";


declare function head:get-collection() {
    map {
        "textapi": "0.2.0",
        "title": array {
            map {
                "title": "The Example Collection",
                "type": "main"
            }
        },
        "collector": array {
            map {
                "role": "collector",
                "name": "John Doe"
            }
        },
        "sequence": array {
            map {
                "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/manifest.json",
                "type": "manifest"
            }
        }
    }
};

declare function head:get-manifest() {
    map {
        "textapi": "0.2.0",
        "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/manifest.json",
        "label": "Testdata Manifest 001",
        "sequence": array {
            map {
                "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/403/latest/item.json",
                "type": "item"
            },
            map {
                "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/404/latest/item.json",
                "type": "item"
            },
            map {
                "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/405/latest/item.json",
                "type": "item"
            },
            map {
                "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/500/latest/item.json",
                "type": "item"
            },
            map {
                "id": "https://ahikar-test.sub.uni-goettingen.de/api/textapi/http-status-test/collection/manifest/503/latest/item.json",
                "type": "item"
            }
        },
        "license": array {
            map {
                "id": "CC-BY-NC-SA-4.0"
            }
        }
    }
};