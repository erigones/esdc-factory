#!/bin/bash

SCRIPT="${0}"

log() {
	logger -t "${SCRIPT}" "$@"
}

# Example1: mdget user-script
# Example2: mdget hostname myhost.lan
# Always returns success.
mdget() {
	local key="$1"
	local val=
	local default="$2"

	val="$(/usr/sbin/mdata-get "${key}" 2> /dev/null || true)"
	
	if [[ -n "${val}" ]]; then
		echo "${val}"
	else
		echo "${default}"
	fi

	return 0
}

if [[ -d /var/lib/rc-scripts ]]; then
	for script in /var/lib/rc-scripts/*.sh; do
		SCRIPT="${0}"
		log "Running ${script}"
		SCRIPT="${script}"
		# wait until following subshell exits
		wait -n
		( . "${script}" )
		# end with true so $0 does't end with a non-zero value
		[[ "$?" -ne 0 ]] && log "Script ${script} has failed" || true
	done
fi
