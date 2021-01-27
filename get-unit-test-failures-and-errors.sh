#!/bin/bash

PROBLEMS=$(xmllint --xpath 'count(/tests/PROBLEM)' exist-app/test/ahikar-test-results.xml)

echo $PROBLEMS
