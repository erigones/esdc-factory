#!/bin/bash

# SmartOS zone: /var/zoneinit/includes/21-zabbix.sh
MDATA_PREFIX="org.erigones"
MDATA_KEY="${MDATA_PREFIX}:zabbix_ip"
ZABBIX_AGENT_CONFIG="/opt/local/etc/zabbix/zabbix_agentd.conf"

log "reading metadata key: \"${MDATA_KEY}\""

ZABBIX_IP=$(mdata-get ${MDATA_KEY} 2>/dev/null) || ZABBIX_IP="127.0.0.1"
OS_HOSTNAME=$(mdata-get sdc:hostname 2>/dev/null) || OS_HOSTNAME="localhost"

log "configuring zabbix-agent"

sed -i "s/^Server=.*/Server=${ZABBIX_IP}/" ${ZABBIX_AGENT_CONFIG}
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_IP}/" ${ZABBIX_AGENT_CONFIG}
sed -i "s/^Hostname=.*/Hostname=${OS_HOSTNAME}/" ${ZABBIX_AGENT_CONFIG}

log "starting zabbix-agent"
svcadm enable -r zabbix-agent
