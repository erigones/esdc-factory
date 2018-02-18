#!/bin/bash

set -o xtrace
 
. /lib/svc/share/smf_include.sh

GAME_DIR="/opt/snakepit"

function start_robots() {
	/usr/bin/svcs -a -o FMRI -H | grep "application/robot:player" | while read robot_svc; do
		(sleep 5 && /usr/sbin/svcadm enable "${robot_svc}") &
	done
}

function stop_robots() {
	/usr/bin/svcs -a -o FMRI -H | grep "application/robot:player" | while read robot_svc; do
		/usr/sbin/svcadm disable -s "${robot_svc}"
		robot_uuid="$(svcprop -p "robot/uuid" "${robot_svc}")"
		robot_log="$(svcprop -p "restarter/logfile" "${robot_svc}")"
		tail -c 65536 "${robot_log}" | grep -v "^\[" | base64 | mdata-put "game_robot_${robot_uuid}_log"
	done
}

function start() {
	trap "/usr/sbin/shutdown -y -g0 -i5" INT TERM EXIT
	source "${GAME_DIR}/env/bin/activate"
	export PATH="${GAME_DIR}/env/bin:/usr/local/bin:/opt/local/bin:/usr/bin:/bin"
	export VIRTUAL_ENV="${GAME_DIR}/env"
	export PYTHONPATH="${GAME_DIR}"

	cd "${GAME_DIR}/var/run"
	start_robots
	su nobody -c "${GAME_DIR}/bin/run.py" >> "${GAME_DIR}/var/log/game.log" 2>&1
}

function stop() {
	export PATH="/usr/local/sbin:/usr/local/bin:/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin:/sbin"
	tail -c 131072 "${GAME_DIR}/var/log/game.log" | base64 | mdata-put "game_log"
	cat "${GAME_DIR}/var/run/top_scores.txt" | base64 | mdata-put "game_top_scores"
	stop_robots
}


case "$1" in
	'start'|'stop')
		"$1"
		;;
	*)
		echo "Usage: $0 { start | stop }"
		exit $SMF_EXIT_ERR_FATAL
		;;
esac

exit $SMF_EXIT_OK
