#!/bin/sh

if [[ ! -f /var/lib/provision_success ]]; then
	/usr/sbin/mdata-put esdc_vm_installed true
	touch /var/lib/provision_success
fi
