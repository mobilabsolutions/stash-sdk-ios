#!/bin/bash
git diff --diff-filter=d --name-only | grep -e '\(.*\).swift$' | while read line; do
echo -e "\nFormatting : \033[95m${line}\033[0m"
swiftformat "${line}";
done
