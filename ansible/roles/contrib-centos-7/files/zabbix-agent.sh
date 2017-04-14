#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SCRIPT="${0}"

log() {
	logger -t "${SCRIPT}" "$@"
}

log "Starting post-deploy configuration of Zabbix agent"

ZABBIX_AGENT_CONFIG="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_SETUP_DONE="$(mdata-get org.erigones:zabbix_setup_done 2>/dev/null || echo '')"
log "Metadata key org.erigones:zabbix_setup_done value=${ZABBIX_SETUP_DONE}"

if [[ -z "${ZABBIX_SETUP_DONE}" ]]; then
	ZABBIX_IP="$(mdata-get org.erigones:zabbix_ip 2>/dev/null || echo '')"
	log "Metadata key org.erigones:zabbix_ip value=${ZABBIX_IP}"

	if [[ -n ${ZABBIX_IP} ]]; then
		sed -i "s/^Server=.*/Server=${ZABBIX_IP}/" "${ZABBIX_AGENT_CONFIG}"
		sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_IP}/" "${ZABBIX_AGENT_CONFIG}"
		log "Restarting zabbix-agent"
		systemctl enable zabbix-agent
		systemctl restart zabbix-agent
	else
		log "Disabling zabbix-agent"
		systemctl stop zabbix-agent
		systemctl disable zabbix-agent
	fi

	log "Setting metadata org.erigones:zabbix_setup_done value=true"
	mdata-put org.erigones:zabbix_setup_done true
fi

log "Finished post-deploy configuration of Zabbix agent"
exit 0
