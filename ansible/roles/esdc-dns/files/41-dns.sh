#!/bin/bash

MDATA_PREFIX="org.erigones"
CONFIG_FILE="/opt/local/etc/pdns.conf"

declare -A MDATA_VARS=(
	[pgsql_host]="gpgsql-host"
	[pgsql_port]="gpgsql-port"
	[pgsql_user]="gpgsql-user"
	[pgsql_password]="gpgsql-password"
	[pgsql_dbname]="gpgsql-dbname"
)

log "reading metadata and configuring ${CONFIG_FILE}"

for key in "${!MDATA_VARS[@]}"; do
	config_var="${MDATA_VARS[$key]}"
	mdata_key="${MDATA_PREFIX}:${key}"
	log "reading metadata key: \"${mdata_key}\""
	mdata_value=$(mdata-get "${mdata_key}" 2>/dev/null)

	if [[ $? -eq 0 ]]; then
		log "found metadata key: \"${mdata_key}\" value: \"${mdata_value}\""
		if gsed -i "/^${config_var}=/s/${config_var}.*/${config_var}=${mdata_value}/" "${CONFIG_FILE}"; then
			log "set ${config_var}=${mdata_value} in ${CONFIG_FILE}"
		else
			log "failed to set ${config_var}=${mdata_value} in ${CONFIG_FILE}"
		fi
	else
		log "missing metadata key: \"${mdata_key}\" (ignoring ${config_var} in ${CONFIG_FILE})"
	fi
done

log "starting PowerDNS and PowerDNS recursor"
svcadm enable -s pdns
svcadm enable -s pdns-recursor
