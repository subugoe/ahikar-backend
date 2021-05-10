xquery version "3.1";

(:~
 : This module expands the motifs, which are encoded as processing instructions,
 : to full TEI elements. By doing this, we create a kind of intermediate format
 : for the TEI files that serves as a basis for the HTML creation.
 : 
 : Each motif is converted to a tei:span encompassing everything that is between
 : the beginning of a comment/processing instruction and its end.
 :)

module namespace me="http://ahikar.sub.uni-goettingen.de/ns/motifs-expansion";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function me:main($nodes as node()*)
as node()* {
    for $node in $nodes return
        typeswitch ($node)
        
        case text() return
            if (me:is-node-in-motif($node)) then
                ()
            else
                $node
        
        case processing-instruction() return
            (: motifs starting and ending in the same line :)
            if ($node[self::processing-instruction('oxy_comment_start')]
            and me:is-motif-one-liner($node)) then
                element {QName("http://www.tei-c.org/ns/1.0","span")} {
                    attribute type {"motif"},
                    attribute n {me:get-motif-type($node)},
                    let $comment-end := me:get-next-motif-end($node)
                    let $nodes-inbetween := $node/following-sibling::node()[. >> $node and . << $comment-end]
                    return
                        $nodes-inbetween
                }
            
            (: the first line of a motifs encompassing mulitple lines :)
            else if($node[self::processing-instruction('oxy_comment_start')]
            and not(me:is-motif-one-liner($node))) then
                element {QName("http://www.tei-c.org/ns/1.0","span")} {
                    attribute id {generate-id($node) || "-" || me:determine-motif-part($node)},
                    me:make-core-attributes($node),
                    me:make-next-attribute(generate-id($node), $node),
                    let $last-node-in-line := $node/ancestor::tei:ab/node()[last()]
                    let $nodes-of-line-in-motif := ($node/following-sibling::node()[. << $last-node-in-line], $last-node-in-line)
                    return
                        $nodes-of-line-in-motif
                }
            
            (: the last line of a motifs encompassing mulitple lines :)
            else if($node[self::processing-instruction('oxy_comment_end')]) then
                let $comment-start := me:get-previous-motif-start($node)
                return
                    if (not(me:is-motif-one-liner($comment-start))) then
                        element {QName("http://www.tei-c.org/ns/1.0","span")} {
                            attribute id {generate-id($comment-start) || "-" || me:determine-motif-part($node)},
                            me:make-core-attributes($comment-start),
                            let $first-node-in-line := $node/ancestor::tei:ab/node()[1]
                            let $nodes-of-line-in-motif := ($first-node-in-line, $first-node-in-line/following-sibling::node()[. << $node])
                            return
                                $nodes-of-line-in-motif
                        }
                    else
                        ()
                
            else
                ()
                
        case element(tei:ab) return
            (: one of the middles lines of a motifs encompassing mulitple lines :)
            if (me:is-node-in-motif($node)) then
                let $previous-comment-start := me:get-previous-motif-start($node)
                let $motif-id := generate-id($previous-comment-start)
                return
                    element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
                        $node/@*,
                        element {QName("http://www.tei-c.org/ns/1.0", "span")} {
                            attribute id {$motif-id || "-" || me:determine-motif-part($node)},
                            me:make-core-attributes($previous-comment-start),
                            me:make-next-attribute($motif-id, $node),
                            $node/node()
                        }
                    }
            else
                me:copy-node($node)
            
        default return
            me:copy-node($node)
};

declare function me:is-node-in-motif($node as node())
as xs:boolean {
    let $previous-motif-start := me:get-previous-motif-start($node)
    let $previous-motif-end := me:get-previous-motif-end($node)
    let $next-motif-end :=  me:get-next-motif-end($node)
    return
        $previous-motif-start
        and
        (
            ($previous-motif-end
            and $previous-motif-start[. >> $previous-motif-end and $node << .])
            or
            (not($previous-motif-end)
            and $node[. >> $previous-motif-start and . << $next-motif-end])
        )
};

declare function me:is-motif-one-liner($node as processing-instruction())
as xs:boolean {
    let $comment-end := me:get-next-motif-end($node)
    return
        $node/ancestor::tei:ab = $comment-end/ancestor::tei:ab
};

declare function me:copy-node($node as node()*) {
    if (me:is-node-in-motif($node)) then
        ()
    else
        element {QName("http://www.tei-c.org/ns/1.0", local-name($node))} {
            $node/@*,
            me:main($node/node())
        }
};

declare function me:get-previous-motif-start($node as node())
as processing-instruction()? {
    $node/preceding::processing-instruction('oxy_comment_start')[1]
};

declare function me:get-previous-motif-end($node as node())
as processing-instruction()? {
    $node/preceding::processing-instruction('oxy_comment_end')[1]
};

declare function me:get-next-motif-end($node as node())
as processing-instruction()? {
    $node/following::processing-instruction('oxy_comment_end')[1]
};

declare function me:get-motif-type($motif as processing-instruction())
as xs:string {
    substring-after($motif, "comment=""")
    => substring-before("""")
};

declare function me:determine-motif-part($node as node())
as xs:integer {
    if ($node[self::processing-instruction('oxy_comment_start')]) then
        1
    else
        let $motif-start := me:get-previous-motif-start($node)
        let $motif-line := $motif-start/ancestor::tei:ab
        let $current-line := $node/ancestor::tei:ab
        return
            (: we have to add 2 here because neither $current-line nor $motif-line
            are considered in the computation :)
            count($current-line/preceding-sibling::tei:ab[. >> $motif-line]) + 2
};

declare function me:make-next-attribute($motif-id as xs:string,
    $node as node())
as attribute() {
    attribute next {"#" || $motif-id || "-" || (me:determine-motif-part($node) + 1)}
};

declare function me:make-core-attributes($motif-start as processing-instruction())
as attribute()+ {
    attribute type {"motif"},
    attribute n {me:get-motif-type($motif-start)}
};
