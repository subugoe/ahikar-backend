#!/bin/bash

MD5OLD=$(md5sum exist-app/data/ahikar.css | cut -d ' ' -f 1)
MD5NEW=$(md5sum ahikar.css | cut -d ' ' -f 1)
echo $MD5OLD
echo $MD5NEW
if [ "$MD5OLD" != "$MD5NEW" ]; then 
    echo "CSS needs to be updated"
    mkdir -p /tmp/this && cd /tmp/this || exit
    git clone git@gitlab.gwdg.de:subugoe/ahiqar/backend.git
    mv ../../ahikar.css exist-app/data/ahikar.css
    git add exist-app/data/ahikar.css && git commit -m "update CSS" && git push
else
    echo "CSS does not require an update"
fi