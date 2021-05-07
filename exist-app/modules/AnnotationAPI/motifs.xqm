xquery version "3.1";

(:~
 : This module provides the motifs for Ahikar.
 :
 : @author Michelle Weidling
 : :)

module namespace motifs="http://ahikar.sub.uni-goettingen.de/ns/annotations/motifs";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace commons="http://ahikar.sub.uni-goettingen.de/ns/commons" at "../commons.xqm";


declare function motifs:get-motifs($pages as element(tei:TEI)+,
    $teixml-uri as xs:string)
as map(*)* {
    let $motifs := 
        for $page in $pages return
            $page//processing-instruction('oxy_comment_start')
    for $motif in $motifs return
        motifs:make-map($motif, $teixml-uri)
};

declare function motifs:get-all-motifs-in-document($xml-doc as document-node(),
    $teixml-uri as xs:string)
as map(*)* {
    let $motifs := $xml-doc/descendant::processing-instruction('oxy_comment_start')
    for $motif in $motifs return
        motifs:make-map($motif, $teixml-uri)
};

declare function motifs:make-map($motif as processing-instruction(),
    $teixml-uri as xs:string)
as map(*) {
    let $id := generate-id($motif)
    return
        map {
            "id": $commons:anno-ns || "/" || $teixml-uri || "/annotation-" || $id,
            "type": "Annotation",
            "body": motifs:get-body-object($motif),
            "target": motifs:get-target-information($teixml-uri, $motif)
        }
};

declare function motifs:get-body-object($motif as processing-instruction())
as map(*) {
    map {
        "type": "TextualBody",
        "value": motifs:get-body-value($motif),
        "format": "text/plain",
        "x-content-type": "Motif"
    }
};

declare function motifs:get-body-value($motif as processing-instruction())
as xs:string {
    let $motif-type := substring-after($motif, 'comment="')
        => substring-before('"')
        
    return
        switch ($motif-type)
            case"self_examination_reflection" return "Self-examination/reflection"
            case"social_contacts_no_family" return "Social contacts (no family)"
            case"caution_against_powerful" return "Caution against the powerful"
            case"meekness_showing_respect" return "Meekness/showing respect"
            case"social_contacts_family" return "Social contacts (family)"
            case"loyal_obligation_gods" return "Loyal obligation (gods)"
            case"disciplining_of_sons" return "Disciplining of the sons"
            case"successful_courtier" return "Successful courtier"
            case"wise_fool_sinful" return "Wise fool sinful"
            case"royal_challenges" return "Royal challenged"
            case"treatment_slaves" return "Treatment of slaves"
            case"adherence_wisdom" return "Adherence wisdom"
            case"richness_poverty" return "Richness/poverty"
            case"keeping_secrets" return "Keeping secrets"
            case"parable_animals" return "Parable (animals)"
            case"temptress_women" return "Temptress women"
            case"obeying_parents" return "Obeying parents"
            case"parable_plants" return "Parable (plants)"
            case"burden_debt" return "Burden (debt)"
            case"truth_lying" return "Truth/Lying"
            case"discernment" return "Discernment"
            case"air_castle" return "Air castle"
            case"image_king" return "Image of the king"
            case"intrigue" return "Intrigue"
            case"quarrel" return "Quarrel"
            default return "Unknown motif."
};

declare function motifs:get-target-information($teixml-uri as xs:string,
    $motif as processing-instruction())
as map(*) {
    map {
        "id": $commons:anno-ns || "/" || $teixml-uri || "/"|| generate-id($motif),
        "format": "text/xml",
        "language": $motif/ancestor-or-self::*[@xml:lang][1]/@xml:lang/string()
    }
};
