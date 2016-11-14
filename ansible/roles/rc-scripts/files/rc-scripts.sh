#!/bin/bash

SCRIPT="${0}"

log() {
	logger -t "${SCRIPT}" "$@"
}

if [[ -d /var/lib/rc-scripts ]]; then
	for script in /var/lib/rc-scripts/*.sh; do
		log "Running ${script}"
		SCRIPT="${script}"
		( . "${script}" )
	done
fi
