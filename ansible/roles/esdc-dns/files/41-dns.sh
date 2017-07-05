#!/bin/bash

MDATA_PREFIX="org.erigones"
PDNS_CONFIG="/opt/local/etc/pdns.conf"
PDNS_RECURSOR_CONFIG="/opt/local/etc/recursor.conf"

declare -A PDNS_MDATA=(
	[pgsql_host]="gpgsql-host"
	[pgsql_port]="gpgsql-port"
	[pgsql_user]="gpgsql-user"
	[pgsql_password]="gpgsql-password"
	[pgsql_dbname]="gpgsql-dbname"
)

declare -A PDNS_RECURSOR_MDATA=(
	[recursor_forwarders]="forward-zones-recurse=."
)

update_config() {
	local mdata_key="${1}"
	local config_var="${2}"
	local config_file="${3}"
	local mdata_value

	log "reading metadata key: \"${mdata_key}\""
	mdata_value=$(mdata-get "${mdata_key}" 2>/dev/null)

	# shellcheck disable=SC2181
	if [[ $? -eq 0 ]]; then
		log "found metadata key: \"${mdata_key}\" value: \"${mdata_value}\""
		if gsed -i "/^${config_var}=/s/${config_var}.*/${config_var}=${mdata_value}/" "${config_file}"; then
			log "set ${config_var}=${mdata_value} in ${config_file}"
		else
			log "failed to set ${config_var}=${mdata_value} in ${config_file}"
		fi
	else
		log "missing metadata key: \"${mdata_key}\" (ignoring ${config_var} in ${config_file})"
	fi
}

log "reading pdns metadata and configuring ${PDNS_CONFIG}"
for key in "${!PDNS_MDATA[@]}"; do
	update_config "${MDATA_PREFIX}:${key}" "${PDNS_MDATA[$key]}" "${PDNS_CONFIG}"
done

log "reading pdns metadata and configuring ${PDNS_RECURSOR_CONFIG}"
for key in "${!PDNS_RECURSOR_MDATA[@]}"; do
	update_config "${MDATA_PREFIX}:${key}" "${PDNS_RECURSOR_MDATA[$key]}" "${PDNS_RECURSOR_CONFIG}"
done

log "starting PowerDNS and PowerDNS recursor"
svcadm enable -s pdns
svcadm enable -s pdns-recursor
