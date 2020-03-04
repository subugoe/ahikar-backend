#!/bin/bash

echo CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME}

case ${CI_COMMIT_REF_NAME} in
"master")
  echo "PORT=8092" > .env
  ;;
"develop")
  echo "PORT=8093" > .env
  ;;
*)
  echo "PORT=8094" > .env
  ;;
esac
