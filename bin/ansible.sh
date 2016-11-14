#!/bin/bash

if [[ -z "${1}" ]]; then
	echo "Usage: ${0} {build-<app>|clean-<app>|get-<dir>|init|check|imgapi-tree} [version]"
	exit 1
fi

if [ -f /opt/rh/python27/enable ]; then
	. /opt/rh/python27/enable
fi

BASEDIR="$(cd "$(dirname "$0")/.." ; pwd -P)"
ACTION="${1}"
VERSION="${2:-${VERSION:-}}"
EXTRA_VARS="${EXTRA_VARS:-${MAKEFLAGS:-}}"
VERBOSE="${VERBOSE:-}"

if [[ -z "${VERBOSE}" ]]; then 
	VERBOSE=""
else
	VERBOSE="-vvvv"
fi

cd "${BASEDIR}/ansible" || exit 127

# Empty ACTION if it does not contain only alphanumeric characters
[[ -n "${ACTION//[0-9a-z-]/}" ]] && ACTION=""

case "${ACTION}" in
	init|check|imgapi-tree)
		PLAYBOOK="${ACTION}.yml"
		;;
	get-*)
		PLAYBOOK="${ACTION}.yml"

		if [[ ! -f "${PLAYBOOK}" ]]; then
			echo "Unknown download component" >&2
			exit 2
		fi
		;;
	clean-*)
		PLAYBOOK="cleanup.yml"
		VM="${ACTION#*-}"

		if [[ -z "${VM}" ]]; then
			echo "Missing appliance/image name" >&2
			exit 2
		fi

		EXTRA_VARS="${EXTRA_VARS} vm=${VM}"
		;;
	build-*)
		PLAYBOOK="${ACTION}.yml"

		if [[ ! -f "${PLAYBOOK}" ]]; then
			echo "Unknown appliance/image name" >&2
			exit 2
		fi

		if [[ ! "${EXTRA_VARS}" =~ version ]]; then
			if [[ -z "${VERSION}" ]]; then
				EXTRA_VARS="${EXTRA_VARS} version=$(date +%Y%m%d)"
			else
				if [[ "${VERSION}" =~ ^[0-9] ]]; then
					echo "Invalid version" >&2
					exit 3
				fi
				if [[ "${VERSION}" =~ ^v[0-9] ]]; then
					EXTRA_VARS="${EXTRA_VARS} source_version=${VERSION}"
					VERSION="${VERSION#*v}"  # v0.5 -> 0.5
				fi

				EXTRA_VARS="${EXTRA_VARS} version=${VERSION}"

				if [[ "${VERSION}" =~ ^[0-9] ]]; then
					EXTRA_VARS="${EXTRA_VARS} release_type=stable release_version=${VERSION}"
				fi
			fi
		fi
		;;
	*)
		echo "Invalid action" >&2
		exit 1
		;;
esac

EXTRA_VARS="${EXTRA_VARS## -- }"
EXTRA_VARS="${EXTRA_VARS## }"

cat << EOF
--------------------------------------------------------------------------------

          *************** Danube Cloud   Assembly Line ***************          
          *                                                          *
            $0 $@

            - PLAYBOOK="${PLAYBOOK}"
            - EXTRA_VARS="${EXTRA_VARS}"
          *                                                          *
          **************** START: $(date "+%Y-%m-%d %H:%M:%S") ****************

EOF

export FACTORY_BASEDIR="${BASEDIR}"
export PYTHONUNBUFFERED=1
ansible-playbook "${PLAYBOOK}" --extra-vars="${EXTRA_VARS}" ${VERBOSE}
e=$?

if [[ ${e} -eq 0 ]]; then
	ret='\033[0;32mEND\033[0m'
else
	ret='\033[0;31mEND\033[0m'
fi

cat << EOF


          *************** Danube Cloud   Assembly Line ***************
          *                                                          *
            $0 $@

            - PLAYBOOK="${PLAYBOOK}"
            - EXTRA_VARS="${EXTRA_VARS}"
          *                                                          *
EOF
echo -e "          ***************** ${ret}: $(date "+%Y-%m-%d %H:%M:%S") *****************\n"

exit ${e}
