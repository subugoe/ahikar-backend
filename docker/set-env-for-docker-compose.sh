#!/bin/bash

echo CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME}

echo "# THIS FILE IS CREATED BY SCRIPT. DO NOT TOUCH!" > docker/.env

case ${CI_COMMIT_REF_NAME} in
"master")
  echo "PORT=8092" >> docker/.env
  echo "TAG=release" >> docker/.env
  echo "APP_NAME=https://ahikar.sub.uni-goettingen.de/" >> docker/.env
  ;;
"develop")
  echo "PORT=8093" > docker/.env
  echo "TAG=develop" >> docker/.env
  echo "APP_NAME=https://ahikar-dev.sub.uni-goettingen.de/" >> docker/.env
  ;;
*)
  echo "PORT=8094" > docker/.env
  echo "TAG=testing" >> docker/.env
  echo "APP_NAME=https://ahikar-test.sub.uni-goettingen.de/" >> docker/.env
  ;;
esac
