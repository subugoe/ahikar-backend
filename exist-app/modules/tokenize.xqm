xquery version "3.1";

(: 
 : This module deals with the tokenization of the relevant text by identifying
 : the relevant words and wrapping them in a separate tei:w.
 : This tei:w is equipped with a unique ID which contains
 :      - the manuscript's IDNO
 :      - the node ID of the complete text node and
 :      -  the position of the word in focus within the text node
 : 
 : This way, each word is specifically addressable.
 :)

module namespace tokenize="http://ahikar.sub.uni-goettingen.de/ns/tokenize";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "commons.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function tokenize:main($TEI as element(tei:TEI))
as element(tei:TEI) {
    let $id-prefix := commons:make-id-from-idno($TEI)
    let $enhanced-texts :=
        for $text in $TEI//tei:group/tei:text return
            tokenize:add-ids($text, $id-prefix)
    return
        element {QName("http://www.tei-c.org/ns/1.0", "TEI")} {
            $TEI/tei:teiHeader,
            element {QName("http://www.tei-c.org/ns/1.0", "text")} {
                element {QName("http://www.tei-c.org/ns/1.0", "group")} {
                    $enhanced-texts
                }
            }
        }
};

declare function tokenize:add-ids($nodes as node()*,
    $id-prefix as xs:string)
as node()* {
    for $node in $nodes return
        typeswitch ($node)
        case text() return
            if (tokenize:is-text-relevant($node)) then
                tokenize:add-id-to-text($node, $id-prefix)
            else
                $node
            
        case comment() return
            ()
            
        case processing-instruction() return
            ()
            
        default return
            element {QName("http://www.tei-c.org/ns/1.0", $node/local-name())} {
                $node/@*,
                tokenize:add-ids($node/node(), $id-prefix)
            }
};

declare function tokenize:is-text-relevant($text as text())
as xs:boolean {
    if($text[not(ancestor::tei:sic)]
            [not(ancestor::tei:surplus)]
            [not(ancestor::tei:supplied)]
            [not(ancestor::tei:*[@type = "colophon"])]
            [not(ancestor::tei:g)]
            [not(ancestor::tei:unclear)]
            [not(ancestor::tei:catchwords)]
            [not(ancestor::tei:note)]) then
        true()
    else
        false()
};

declare function tokenize:add-id-to-text($text as text(),
    $id-prefix as xs:string)
as element(tei:w)* {
    let $texts := 
        normalize-space($text)
        => tokenize(" ")
    (: since we tokenize the text node we have to consider the position within
    the tokenized sequence for the ID creation :)
    for $iii in 1 to count($texts) return
        if (normalize-space($texts[$iii]) = "") then
            ()
        else
            element{QName("http://www.tei-c.org/ns/1.0", "w")} {
                attribute xml:id {$id-prefix || "_" || generate-id($text) || "_" || $iii},
                attribute type {"token"},
                $texts[$iii]
            }
};
