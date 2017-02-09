#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
DONE_FILE="/var/lib/es-post-deploy.done"
GITLAB_CONFIG_DIR="/etc/gitlab"
GITLAB_CONFIG_FILE="${GITLAB_CONFIG_DIR}/gitlab.rb"
GITLAB_CONFIG_CUSTOM_FILE="${GITLAB_CONFIG_DIR}/es_gitlab.rb"
SCRIPT="${0}"

log() {
	logger -t "${SCRIPT}" "$@"
}


# GitLab
# https://docs.gitlab.com/omnibus/settings/configuration.html
configure_gitlab() {
	init="${1:-}"

	if [[ "${init}" ]]; then
		log "Initializing GitLab configuration"
		GL_external_url_default="https://$(hostname -f)"  # HTTPS by default
	else
		GL_external_url_default=""
	fi

	log "Reading GitLab configuration metadata"
	GL_external_url="$(mdata-get gitlab:external_url || echo "${GL_external_url_default}")"

	if [[ -n "${GL_external_url}" ]]; then
		log "Metadata key gitlab:external_url value=${GL_external_url}"
		if grep -q "^external_url" "${GITLAB_CONFIG_CUSTOM_FILE}"; then
			sed -i.bak "s#^external_url.*#external_url \"${GL_external_url}\"#" "${GITLAB_CONFIG_CUSTOM_FILE}"
		else
			echo "external_url \"${GL_external_url}\"" >> "${GITLAB_CONFIG_CUSTOM_FILE}"
		fi

		if [[ "${GL_external_url:0:6}" == "https:" ]]; then
			if ! grep -q "ssl_certificate" "${GITLAB_CONFIG_CUSTOM_FILE}"; then
				log "Add custom GitLab ssl_certificate and ssl_certificate_key"
				echo "nginx['ssl_certificate'] = \"/etc/pki/tls/certs/server.crt\"" >> "${GITLAB_CONFIG_CUSTOM_FILE}"
				echo "nginx['ssl_certificate_key'] = \"/etc/pki/tls/certs/server.key\"" >> "${GITLAB_CONFIG_CUSTOM_FILE}"
			fi
			if ! grep -q "redirect_http_to_https" "${GITLAB_CONFIG_CUSTOM_FILE}"; then
				log "Enabling GitLab redirect_http_to_https"
				echo "nginx['redirect_http_to_https'] = true" >> "${GITLAB_CONFIG_CUSTOM_FILE}"
			fi
		else
			if grep -q "redirect_http_to_https" "${GITLAB_CONFIG_CUSTOM_FILE}"; then
				log "Disabling GitLab redirect_http_to_https"
				sed -i.bak "s/^nginx['redirect_http_to_https'].*/d" "${GITLAB_CONFIG_CUSTOM_FILE}"
			fi
		fi
	fi

	log "Running gitlab-ctl reconfigure"
	gitlab-ctl reconfigure
}

if [[ -f "${DONE_FILE}" ]]; then
	log "Found ${DONE_FILE} - skipping post-deploy configuration"
	# Update GitLab settings according to VM metadata
	configure_gitlab
	exit 0
fi

log "Starting post-deploy configuration"

# /root/.ssh/authorized_keys
AUTHORIZED_KEYS="$(mdata-get root_authorized_keys || echo '')"
log "Populating authorized_keys"
mkdir -pm 700 /root/.ssh
echo "${AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

log "Generating SSL certificate"
openssl req -new -nodes -x509 \
-subj "/C=SK/ST=Slovakia/L=Bratislava/O=IT/CN=*.*" \
-days 3650 \
-keyout /etc/pki/tls/certs/server.key \
-out /etc/pki/tls/certs/server.crt \
-extensions v3_ca

cat /etc/pki/tls/certs/server.key /etc/pki/tls/certs/server.crt > /etc/pki/tls/certs/server.pem
chown root:root /etc/pki/tls/certs/server.pem
chmod 0600 /etc/pki/tls/certs/server.pem
chmod 0600 /etc/pki/tls/certs/server.key

# Zabbix Agent
ZABBIX_AGENT_CONFIG="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_IP="$(mdata-get org.erigones:zabbix_ip 2>/dev/null || echo '127.0.0.1')"
log "Metadata key org.erigones:zabbix_ip value=${ZABBIX_IP}"
sed -i "s/^Server=.*/Server=${ZABBIX_IP}/" "${ZABBIX_AGENT_CONFIG}"
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_IP}/" "${ZABBIX_AGENT_CONFIG}"
log "Restarting zabbix-agent"
systemctl restart zabbix-agent

# Initialize GitLab configuration
if [[ ! -d "${GITLAB_CONFIG_DIR}" ]]; then
	mkdir "${GITLAB_CONFIG_DIR}"
	chmod 0755 "${GITLAB_CONFIG_DIR}"
fi

if [[ ! -f "${GITLAB_CONFIG_FILE}" ]]; then
	touch "${GITLAB_CONFIG_FILE}"
	chmod 0600 "${GITLAB_CONFIG_FILE}"
fi

echo "# Custom GitLab configuration - updated automatically according to VM metadata" > "${GITLAB_CONFIG_CUSTOM_FILE}"
chmod 0600 "${GITLAB_CONFIG_CUSTOM_FILE}"
echo "# Custom GitLab configuration - updated automatically according to VM metadata" >> "${GITLAB_CONFIG_FILE}"
echo "from_file \"${GITLAB_CONFIG_CUSTOM_FILE}\"" >> "${GITLAB_CONFIG_FILE}"

# Update GitLab settings according to VM metadata
configure_gitlab true

# Finished
touch "${DONE_FILE}"
log "Finished post-deploy configuration"
exit 0
