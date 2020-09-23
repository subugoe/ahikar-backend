xquery version "3.1";

(:~
 : This module normalizes Syriac and Arabic text by removing all diacritics from
 : them.
 : 
 : The following Unicode code blocks are sorted out:
 : * Arabic
 :      * Tashkil from ISO 8859-6
 :      * Combining maddah and hamza
 :      * Other combining marks
 : * Syriac
 :      * Syriac punctuation and signs
 :      * Syriac points (vowels)
 :      * Syriac marks
 : 
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
        1852,
        1853,
        1854,
        1855
    );
    
declare variable $norm:syriac-marks :=
    (
        1856,
        1857,
        1858,
        1859,
        1860,
        1861,
        1862,
        1863,
        1864,
        1865,
        1866
    );
    
declare variable $norm:syriac-punctuation :=
    (
        1792,
        1793,
        1794,
        1795,
        1796,
        1797,
        1798,
        1799,
        1800,
        1801,
        1802,
        1803,
        1804,
        1805
    );
    
declare variable $norm:arabic-tashkil-and-combining-marks :=
    (
        1611,
        1612,
        1613,
        1614,
        1615,
        1616,
        1617,
        1618,
        1619,
        1620,
        1621,
        1622,
        1623,
        1624,
        1625,
        1626,
        1627,
        1628,
        1629,
        1630
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
        $norm:syriac-marks,
        $norm:syriac-punctuation,
        $norm:syriac-vowels,
        $norm:arabic-tashkil-and-combining-marks
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
