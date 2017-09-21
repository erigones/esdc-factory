#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
DONE_FILE="/var/lib/es-post-deploy.done"
SCRIPT="${0}"

log() {
	logger -t "${SCRIPT}" "$@"
}

if [[ -f "${DONE_FILE}" ]]; then
	log "Found ${DONE_FILE} - skipping post-deploy configuration"
	exit 0
fi

log "Starting post-deploy configuration"

# /root/.ssh/authorized_keys
AUTHORIZED_KEYS="$(mdata-get root_authorized_keys || echo '')"
log "Populating authorized_keys"
mkdir -pm 700 /root/.ssh
echo "${AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

# Zabbix Agent
ZABBIX_AGENT_CONFIG="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_IP="$(mdata-get org.erigones:zabbix_ip 2>/dev/null || echo '127.0.0.1')"
log "Metadata key org.erigones:zabbix_ip value=${ZABBIX_IP}"
sed -i "s/^Server=.*/Server=${ZABBIX_IP}/" "${ZABBIX_AGENT_CONFIG}"
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_IP}/" "${ZABBIX_AGENT_CONFIG}"
log "Restarting zabbix-agent"
systemctl restart zabbix-agent

# Finished
touch "${DONE_FILE}"
log "Finished post-deploy configuration"
exit 0
