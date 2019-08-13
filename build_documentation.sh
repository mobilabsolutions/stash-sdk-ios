#!/usr/bin/env bash
set -e

schemes=( "StashCore" "StashBSPayone" "StashBraintree" "StashAdyen" )

for scheme in "${schemes[@]}"
do
    jazzy -m "${scheme}" -o ./docs/"${scheme}" -x -scheme,"${scheme}"
done
