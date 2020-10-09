xquery version "3.1";

(:~
 : This module normalizes Syriac and Arabic text by removing all diacritics from
 : them.
 : 
 : The following Unicode code blocks are sorted out:
 : * Syriac
 :      * Syriac punctuation and signs
 :      * Syriac points (vowels)
 :      * Syriac marks
 : 
 : The vocalization of the Arabic text is kept.
 :
 : @see https://unicode-table.com/en/blocks/arabic/
 : @see https://unicode-table.com/en/blocks/syrian/
 :)

module namespace norm="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization";

declare variable $norm:syriac-vowels :=
    (
        1840,
        1841,
        1842,
        1843,
        1844,
        1845,
        1846,
        1847,
        1848,
        1849,
        1850,
        1851,
        1853,
        1854
    );    

declare function norm:get-txt-without-diacritics($txt as xs:string)
as xs:string {
    string-to-codepoints($txt)
    => norm:remove-codepoints()
    => norm:restore-text-from-codepoints()
};


declare function norm:remove-codepoints($codepoints as xs:integer+)
as xs:integer+ {
    let $diacritics := 
    (
        $norm:syriac-vowels
    )
    for $cp in $codepoints return
        if ($cp = $diacritics)  then
            ()
        else
            $cp
};


declare function norm:restore-text-from-codepoints($codepoints as xs:integer+)
as xs:string {
    codepoints-to-string($codepoints)
};
