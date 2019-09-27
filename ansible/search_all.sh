#!/usr/bin/bash

if [[ -z "$1" ]]; then
	echo "Searches all strings in .yml files in this repo."
	echo "Usage:   $0 <ansible_var>"
	echo "Example: $0 platform_version"
	exit 1
fi

find "$(dirname $0)" -type f -name \*.yml -exec grep -i "${1}" {} +
