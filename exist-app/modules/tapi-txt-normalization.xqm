xquery version "3.1";

(:~
 : This module normalizes Syriac and Arabic text by removing all diacritics from
 : them.
 : 
 : The following Unicode code blocks are sorted out:
 : * Syriac
 :      * Syriac points (vowels)
 : 
 : The vocalization of the Arabic text is kept.
 :
 : @see https://unicode-table.com/en/blocks/arabic/
 : @see https://unicode-table.com/en/blocks/syrian/
 :)

module namespace norm="http://ahikar.sub.uni-goettingen.de/ns/tapi/txt/normalization";

declare variable $norm:syriac-vowels :=
    (
        1840 to 1855 (: decimal for unicode U+073A and following :)
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
