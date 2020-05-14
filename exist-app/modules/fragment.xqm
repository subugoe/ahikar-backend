xquery version "3.1";

(:~
 : This module is an implementation of David Sewell's recommendation on how to
 : get TEI chunks from an XML.
 :
 : See https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery for more
 : information and the original suggestion.
 :
 :)

module namespace fragment="https://wiki.tei-c.org/index.php?title=Milestone-chunk.xquery";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare %private function local:get-common-ancestor($element as element(), $start-node as node(), $end-node as node())
as element()
{
    let $element :=
        ($element//*[. is $start-node]/ancestor::* intersect $element//*[. is $end-node]/ancestor::*)[last()]
    return
        $element
};

declare function local:get-fragment(
    $node as node()*,
    $start-node as element(),
    $end-node as element(),
    $include-start-and-end-nodes as xs:boolean,
    $empty-ancestor-elements-to-include as xs:string+
) as node()*
{
    typeswitch ($node)
    case element() return
        if ($node is $start-node or $node is $end-node)
        then
            if ($include-start-and-end-nodes)
            then $node
            else ()
        else
            if (some $node in $node/descendant::* satisfies ($node is $start-node or $node is $end-node))
            then
                element {node-name($node)}
                {
                (:the xml attributes that govern their descendants are carried over to the fragment;
                if the fragment has several layers before it reaches text nodes, this information is duplicated, but this does no harm:)
                if ($node/@xml:base)
                then attribute{'xml:base'}{$node/@xml:base}
                else
                    if ($node/ancestor::*/@xml:base)
                    then attribute{'xml:base'}{$node/ancestor::*/@xml:base[1]}
                    else (),
                if ($node/@xml:space)
                then attribute{'xml:space'}{$node/@xml:space}
                else
                    if ($node/ancestor::*/@xml:space)
                    then attribute{'xml:space'}{$node/ancestor::*/@xml:space[1]}
                    else (),
                if ($node/@xml:lang)
                then attribute{'xml:lang'}{$node/@xml:lang}
                else
                    if ($node/ancestor::*/@xml:lang)
                    then attribute{'xml:lang'}{$node/ancestor::*/@xml:lang[1]}
                    else ()
                ,
                (:carry over the nearest of preceding empty elements that have significance for the fragment; though amy element could be included here, the idea is to allow empty elements such as handShift to be carried over:)
                for $empty-ancestor-element-to-include in $empty-ancestor-elements-to-include
                return
                    $node/preceding::*[local-name(.) = $empty-ancestor-element-to-include][1]
                ,
                (:recurse:)
                for $node in $node/node()
                return local:get-fragment($node, $start-node, $end-node, $include-start-and-end-nodes, $empty-ancestor-elements-to-include) }
        else
        (:if an element follows the start-node or precedes the end-note, carry it over:)
        if ($node >> $start-node and $node << $end-node)
        then $node
        else ()
    default return
        (:if a text, comment or PI node follows the start-node or precedes the end-node, carry it over:)
        if ($node >> $start-node and $node << $end-node)
        then $node
        else ()
};


declare function fragment:get-fragment-from-doc(
    $node as node()*,
    $start-node as element(),
    $end-node as element(),
    $wrap-in-first-common-ancestor-only as xs:boolean,
    $include-start-and-end-nodes as xs:boolean,
    $empty-ancestor-elements-to-include as xs:string+
) as node()*
{
    if ($node instance of element())
    then
        let $node :=
            if ($wrap-in-first-common-ancestor-only)
            then local:get-common-ancestor($node, $start-node, $end-node)
            else $node
            return
                local:get-fragment($node, $start-node, $end-node, $include-start-and-end-nodes, $empty-ancestor-elements-to-include)
    else
        if ($node instance of document-node())
        then fragment:get-fragment-from-doc($node/element(), $start-node, $end-node, $wrap-in-first-common-ancestor-only, $include-start-and-end-nodes, $empty-ancestor-elements-to-include)
        else error(QName("fragment", "one"), "no document-node provided")
};
