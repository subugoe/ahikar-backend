xquery version "3.1";

(:~
 : This module transforms TEI to XHTML according to the needs of the Ahiqar project.
 : 
 : There are four types of outcomes of the transformation:
 :  * some elements are ignored ($tei2html:ignored-elements),
 :  * some elements are transformed to xhtml:div ($tei2html:block-elements),
 :  * elements that reference another element (indicated by @target, @next, and
 :    @prev) are transformed to xhtml:a,
 :  * the rest of the elements are transformed to xhtml:span.
 : 
 : In any case the resulting XHTML element hold the original TEI element's name
 : in its class attribute as well as all attributes.
 : The id attribute, which has been added automatically by the TextAPI and holds 
 : the TEI node number, is preserved in any case.
 : 
 : @see https://intranet.sub.uni-goettingen.de/display/prjAhiqar/Text+Styling+Specification
 :)

module namespace tei2html="http://ahikar.sub.uni-goettingen.de/ns/tei2html";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace tei2html-text="http://ahikar.sub.uni-goettingen.de/ns/tei2html/textprocessing" at "tei2html-textprocessing.xqm";

declare variable $tei2html:block-elements := ("ab", "body", "cb", "l", "lg");
declare variable $tei2html:ignored-elements := ("lb", "milestone", "pb");


declare function tei2html:transform($nodes as node()*)
as node()* {
    for $node in $nodes return
        typeswitch ($node)
        case text() return
            tei2html-text:process-text($node)
            
        case element(tei:body) return
            if (tei2html:has-page-content($node)) then
                tei2html:make-default-return($node)
            else
                tei2html:make-vacant-page()
            
        case element(tei:head) return
            element xhtml:h1 {
                attribute id {$node/@id},
                attribute class
                {
                    tei2html:make-class-attribute-values($node)
                },
                tei2html:transform($node/node())
            }
            
        case element(tei:w) return
            (
                element xhtml:span {
                    attribute id {$node/@xml:id},
                    attribute class {"token"},
                    tei2html:transform($node/node())
                },
                text{" "}
            )
            
        default return
            tei2html:make-default-return($node)
};

declare function tei2html:has-page-content($body as element(tei:body))
as xs:boolean {
    $body/descendant::*
    and $body/descendant::text()[matches(., "[\w]")]
};

declare function tei2html:make-default-return($node as node()*)
as node()* {
    if (tei2html:is-block-element($node)) then
        local:make-xhtml-div($node)
        
    else if (tei2html:references-another-element($node)) then
        tei2html:make-xhtml-a($node)
        
    else if (tei2html:is-ignored-element($node)) then
        ()
        
    else
        local:make-xhtml-span($node)
};

declare function tei2html:is-block-element($node as node()*)
as xs:boolean {
    local-name($node) = $tei2html:block-elements
};

declare function tei2html:is-ignored-element($node as node()*)
as xs:boolean {
    local-name($node) = $tei2html:ignored-elements
    or $node[self::comment()]
    or $node[self::processing-instruction()]
};

declare function local:make-xhtml-span($element as element())
as element(xhtml:span) {
    element xhtml:span {
        attribute id {$element/@id},
        attribute class {
            tei2html:make-class-attribute-values($element)
        },
        tei2html:transform($element/node())
    }
};

declare function local:make-xhtml-div($element as element())
as element(xhtml:div) {
    element xhtml:div {
        attribute id {$element/@id},
        attribute class {
            tei2html:make-class-attribute-values($element)
        },
        tei2html:transform($element/node())
    }
};

declare function tei2html:make-class-attribute-values($element as element())
as xs:string {
    let $element-name := $element/local-name()
    let $attribute-values :=
        for $attr in $element/(@* except @id) return
            if (contains($attr, "red")) then
                "red"
            else
                $attr
    return
        string-join(($element-name, $attribute-values), " ")
};

declare function tei2html:make-vacant-page()
as element(xhtml:div) {
    element xhtml:div {
        attribute class {"vacant-page"}
    }
};


declare function tei2html:references-another-element($node as node())
as xs:boolean {
    exists($node/@next)
    or exists($node/@prev)
    or exists($node/@target)
};


declare function tei2html:make-xhtml-a($element as element())
as element(xhtml:a) {
    element xhtml:a {
        attribute id {$element/@id},
        attribute class {$element/local-name()},
        attribute href {tei2html:get-href-value($element)},
        tei2html:transform($element/node())
    }
};


(: While references work on basis of @xml:id (e.g. 'seg_1') in TEI, we link to
 : the TEI node's ID that has been generated by generate-id() instead in XHTML.
 : The reason for this is that we also use the node ID for the AnnotationAPI so
 : the data we receive at this point looks like this:
 : 
 : <seg id="N.1.1.1.2.3" type="colophon">...</seg>
 : 
 : Since @id has to preserved for the AnnotationAPI, we cannot simply store
 : @xml:id in @id.
 :)
declare function tei2html:get-href-value($element as element())
as xs:string? {
    let $xmlid := tei2html:get-referenced-xmlid($element)
    let $referenced-id := tei2html:find-referenced-node-id($element, $xmlid)
    return
        "#" || $referenced-id
};

declare function tei2html:find-referenced-node-id($element as element(),
    $xmlid as xs:string)
as xs:string? {
    $element/root()//*[@xml:id = $xmlid]/@id
};

declare function tei2html:get-referenced-xmlid($element as element())
as xs:string? {
    if ($element/@next) then
        $element/@next => substring-after("#")
    else if ($element/@prev) then
        $element/@prev => substring-after("#")
    else if ($element/@target) then
        tokenize($element/@target, " ")[1]
        => substring-after("#")
    else
        ()
};
