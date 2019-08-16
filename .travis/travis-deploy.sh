#!/bin/bash

set -e;
set -o pipefail;
    
mkdir fastlane/Certificates;
touch fastlane/Certificates/distribution.p12;
touch fastlane/Certificates/distribution_base64;

echo "${CERTIFICATE}" > fastlane/Certificates/distribution_base64;

base64 -D fastlane/Certificates/distribution_base64 -o fastlane/Certificates/distribution.p12;

echo "Will distribute application to Beta";
fastlane beta;
OPERATION_RESULT="$?";

echo "Removing certificate folder";
rm -rf fastlane/Certificates;

echo "Operation result: $OPERATION_RESULT";

if [ $OPERATION_RESULT -neq 0 ]; then
    echo "An error occurred while distributing!";
    exit 1;
fi