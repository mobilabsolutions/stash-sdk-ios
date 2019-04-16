#!/usr/bin/env bash
set -e

schemes=( "MobilabPaymentCore" "MobilabPaymentBSPayone" "MobilabPaymentBraintree" "MobilabPaymentAdyen" )

for scheme in "${schemes[@]}"
do
    jazzy -m "${scheme}" -o ./docs/"${scheme}" -x -scheme,"${scheme}"
done
