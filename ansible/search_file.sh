#!/usr/bin/bash

if [[ -z "$1" ]]; then
	echo "Searches all filename strings in this repo."
	echo "Usage:   $0 <ansible_var>"
	echo "Example: $0 prompt-config"
	exit 1
fi

find "$(dirname $0)/.." -type f -name "*$1*"
