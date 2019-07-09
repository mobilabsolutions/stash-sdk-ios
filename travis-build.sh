#!/bin/bash

set -e;
set -o pipefail;

echo "Starting Test run";
fastlane test && echo "Building Objective-C Sample"\
    && xcodebuild -workspace "$WORKSPACE_NAME" -scheme "Sample-ObjC" -destination "$DESTINATION" | xcpretty -f `xcpretty-travis-formatter`;

TESTING_RESULT="$?";
 
if [ "$TESTING_RESULT" -eq 0 ] && [ "$TRAVIS_PULL_REQUEST" = 'false' ] && [ "$TRAVIS_BRANCH" = 'master' ]; then
 
    mkdir fastlane/Certificates;
    touch fastlane/Certificates/distribution.p12;
    touch fastlane/Certificates/distribution_base64;
 
    echo "${CERTIFICATE}" > fastlane/Certificates/distribution_base64;
 
    base64 -D fastlane/Certificates/distribution_base64 -o fastlane/Certificates/distribution.p12;
    echo "Testing succeeded. Next steps will be taken";
 
    echo "Will distribute application to Beta";
    fastlane beta;
    OPERATION_RESULT="$?";
 
    echo "Removing certificate folder";
    rm -rf fastlane/Certificates;
 
    echo "Operation result: $OPERATION_RESULT";
 
    if [ "$OPERATION_RESULT" -neq 0 ]; then
        echo "An error occurred while distributing!";
        exit 1;
    fi

elif [ "$TESTING_RESULT" -eq 0 ]; then
    echo "Testing succeeded but not on master branch so will not distribute.";
    exit 0;
else
    echo "An error occurred while testing; Will not go further";
    exit 1;
fi