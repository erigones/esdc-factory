#!/bin/bash

if [[ -f /var/lib/provision_odoo_success ]]; then
	log "Odoo instance already provisioned."
	exit 0
fi

log "Starting odoo provisioning..."
ODOO_ADMIN_PASSWD="$(mdget odoo_admin_passwd)"
FQDN="$(mdget hostname "${HOSTNAME}")"
CERTS_PATH="/etc/nginx/ssl"

if [[ ! -f "${CERTS_PATH}/odoo.key" ]]; then
	mkdir -p "${CERTS_PATH}"
	log "Generating nginx ssl cert for odoo..."
	openssl req -x509 -sha256 -nodes -days 3650 -subj "/CN=${FQDN}/O=odoo/C=EU" \
		-newkey rsa:2048 -keyout "${CERTS_PATH}/odoo.key" -out "${CERTS_PATH}/odoo.crt" > /dev/null
fi

sed -i'' "s/odoo.mycompany.com/${FQDN}/g" /etc/nginx/sites-enabled/odoo

if [[ -n "${ODOO_ADMIN_PASSWD}" ]]; then
	sed -i'' "s/^ *; *admin_passwd *=.*$/admin_passwd = ${ODOO_ADMIN_PASSWD}/" /etc/odoo/odoo.conf
fi

log "Odoo provision success. Starting services."
systemctl enable odoo
systemctl enable nginx
systemctl start odoo
systemctl start nginx

touch /var/lib/provision_odoo_success
