#!/bin/bash

failures=$(xmllint --xpath '/tests/testsuites/testsuite/@failures' exist-app/test/ahikar-test-results.xml | egrep -o "[0-9]+")
errors=$(xmllint --xpath '/tests/testsuites/testsuite/@errors' exist-app/test/ahikar-test-results.xml | egrep -o "[0-9]+")

problem_sum=0

for FAILURE in $failures $errors
do
    let problem_sum+=$FAILURE
done

echo $problem_sum
