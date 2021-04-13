#!/bin/bash

MD5OLD=$(md5sum exist-app/data/ahikar.css | cut -d ' ' -f 1)
MD5NEW=$(md5sum ahikar.css | cut -d ' ' -f 1)
if [ "$MD5OLD" != "$MD5NEW" ]; then 
    echo "CSS needs to be updated"
    mv ahikar.css exist-app/data/ahikar.css
    git add exist-app/data/ahikar.css && git commit -m "update CSS" && git push
else
    echo "CSS does not require an update"
fi