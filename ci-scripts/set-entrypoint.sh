#!/bin/bash
#  this script sets the entrypoint for TIDO that depends on the
#  branch it is build from.


echo CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME}

case ${CI_COMMIT_REF_NAME} in
"main")
  sed -i "s ahikar.*\.sub ahikar.sub g" tido/dist/index.html
  echo "set entrypoint for production"
  ;;
"develop")
  sed -i "s ahikar.*\.sub ahikar-dev.sub g" tido/dist/index.html
  echo "set entrypoint for develop aka staging"
  ;;
*)
  sed -i "s ahikar.*\.sub ahikar-test.sub g" tido/dist/index.html
  echo "set entrypoint for testing"
  ;;
esac
