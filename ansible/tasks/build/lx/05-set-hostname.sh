#!/bin/bash

set -e

NEWHOSTNAME="$(mdget hostname)"

if [[ -n "${NEWHOSTNAME}" ]] && [[ "${NEWHOSTNAME}" != "${HOSTNAME}" ]]; then
	hostnamectl set-hostname "${NEWHOSTNAME}"
fi
