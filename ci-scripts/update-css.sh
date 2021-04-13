#!/bin/bash

MD5OLD=$(md5sum exist-app/data/ahikar.css | cut -d ' ' -f 1)
MD5NEW=$(md5sum ahikar.css | cut -d ' ' -f 1)

if [ "$MD5OLD" != "$MD5NEW" ]; then 
    echo "CSS needs to be updated"
    WKDIR=$(pwd)
    mkdir -p /tmp/this && cd /tmp/this || exit
    git clone git@gitlab.gwdg.de:subugoe/ahiqar/backend.git
    ls "$WKDIR"
    mv "$WKDIR"/ahikar.css exist-app/data/ahikar.css
    git add exist-app/data/ahikar.css && git commit -m "update CSS" && git push
else
    echo "CSS does not require an update"
fi