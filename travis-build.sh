#!/bin/bash
set -e;
set -o pipefail;

echo "Starting Test run";

if [ "$TEST_SUITE" = 'unit' ]; then
    echo "Running unit tests.";
    fastlane unitTest;

    echo "Building Objective-C Sample";
    xcodebuild -workspace "$WORKSPACE_NAME" -scheme "Sample-ObjC" -destination "$DESTINATION" | xcpretty -f `xcpretty-travis-formatter`;
elif [ "$TEST_SUITE" = 'ui' ]; then
    echo "Running UI tests.";
    fastlane uiTest;
else 
    echo "Running unit and UI tests.";
    fastlane test;

    echo "Building Objective-C Sample";
    xcodebuild -workspace "$WORKSPACE_NAME" -scheme "Sample-ObjC" -destination "$DESTINATION" | xcpretty -f `xcpretty-travis-formatter`;
fi