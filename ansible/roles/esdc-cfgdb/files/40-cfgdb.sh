#!/bin/bash

# SmartOS zone: /var/zoneinit/includes/40-cfgdb.sh
zkcli() {
	cmd="${1}"

	if echo "${cmd}" | zkCli.sh > /dev/null; then
		log "ZK command \"${cmd}\" was successful"
		return 0
	else
		log "ZK command \"${cmd}\" failed"
		return 1
	fi
}

CFGDB_INITIALIZED="/var/lib/cfgdb.initialized"
ZK_REST_HTTP_SVC="svc:/application/cfgdb-zk-rest"
ZK_REST_HTTP_SSL_CERT="/usr/local/etc/zk_rest_http_ssl.crt"
ZK_REST_HTTP_SSL_KEY="/usr/local/etc/zk_rest_http_ssl.key"

if [[ -f "${CFGDB_INITIALIZED}" ]]; then
    log "found ${CFGDB_INITIALIZED} - skipping cfgdb initialization"
    exit 0
fi

CFGDB_NODE="$(mdata-get org.erigones:cfgdb_node 2>/dev/null || echo '/esdc')"
log "metadata key org.erigones:cfgdb_node value=${CFGDB_NODE}"

CFGDB_DATA="$(mdata-get org.erigones:cfgdb_data 2>/dev/null || echo 'DanubeCloud')"
log "metadata key org.erigones:cfgdb_data value=${CFGDB_DATA}"

CFGDB_USERNAME="$(mdata-get org.erigones:cfgdb_username 2>/dev/null || echo 'esdc')"
log "metadata key org.erigones:cfgdb_username value=${CFGDB_USERNAME}"

CFGDB_PASSWORD="$(mdata-get org.erigones:cfgdb_password 2>/dev/null)"
log "metadata key org.erigones:cfgdb_password value=${CFGDB_PASSWORD}"

if [[ -n "${CFGDB_USERNAME}" && -n "${CFGDB_PASSWORD}" ]]; then
	CFGDB_AUTH="$(zkPasswd.sh ${CFGDB_USERNAME}:${CFGDB_PASSWORD} | awk -F '->' '{ print $2 }')"
	log "ZK ACL is ${CFGDB_AUTH}"
	zkcli "addauth digest ${CFGDB_USERNAME} ${CFGDB_PASSWORD}"
	zkcli "create ${CFGDB_NODE} ${CFGDB_DATA} digest:${CFGDB_AUTH}:crdwa"
else
	zkcli "create ${CFGDB_NODE} ${CFGDB_DATA}"
fi

ZK_REST_SSL_CERT="$(mdata-get org.erigones:cfgdb_zk_rest_ssl_cert 2>/dev/null || echo '')"
log "metadata key org.erigones:cfgdb_zk_rest_ssl_cert value=${ZK_REST_SSL_CERT}"

ZK_REST_SSL_KEY="$(mdata-get org.erigones:cfgdb_zk_rest_ssl_key 2>/dev/null || echo '')"
log "metadata key org.erigones:cfgdb_zk_rest_ssl_key value=${ZK_REST_SSL_KEY}"

svcadm disable -s "${ZK_REST_HTTP_SVC}"

if [[ -n "${ZK_REST_SSL_CERT}" && -n "${ZK_REST_SSL_KEY}" ]]; then
	echo "${ZK_REST_SSL_CERT}" > "${ZK_REST_HTTP_SSL_CERT}"
	echo "${ZK_REST_SSL_KEY}" > "${ZK_REST_HTTP_SSL_KEY}"
	chown nobody "${ZK_REST_HTTP_SSL_KEY}"
	chmod 0400 "${ZK_REST_HTTP_SSL_KEY}"
	svcadm enable -s "${ZK_REST_HTTP_SVC}"
fi

touch "${CFGDB_INITIALIZED}"
