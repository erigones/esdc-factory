GAME_DIR="/opt/snakepit"

function create_robot_user() {
	local uuid="$1"
	local user

	user="u$(echo "${uuid}" | cut -d '-' -f 1)"
	echo "${user}"

	useradd -s /usr/bin/false "${user}"
	projadd -K "project.max-lwps=(privileged,2,deny)" -K "project.cpu-cap=(privileged,50,deny)" -K "rcap.max-rss=64M" -K "process.max-file-size=(privileged,256M,deny)" "user.${user}"
}

function robot_instance_manifest() {
	local user="$1"
	local uuid="$2"
	local code="$3"
	local name="$4"

	cat << EOF
<?xml version="1.0"?>
<!DOCTYPE service_bundle SYSTEM "/usr/share/lib/xml/dtd/service_bundle.dtd.1">
<service_bundle type='manifest' name='export'>
    <service name='application/robot' type='service' version='0'>
        <instance name='player-${uuid}' enabled='false'>
            <property_group name='robot' type='application'>
                <propval name='uuid' type='astring' value='${uuid}' />
                <propval name='code' type='astring' value='${code}' />
                <propval name='name' type='astring' value='${name}' />
            </property_group>
            <property_group name='start' type='method'>
                <propval name='user' type='astring' value='${user}' />
            </property_group>
        </instance>
    </service>
</service_bundle>
EOF
}

##########################################
log "Initializing Snakepit"

game_mgmt_ip="$(mdata-get game_mgmt_ip)"
if [[ -n "${game_mgmt_ip}" ]]; then
	log "Allowing Snakepit game server port from ${game_mgmt_ip}"
	echo "pass in quick proto tcp from ${game_mgmt_ip} to any port = 8111 keep state" >> /etc/ipf/ipf.conf
	svcadm restart ipfilter
fi

game_settings="$(mdata-get game_settings | base64 -d)"
if [[ -n "${game_settings}" ]]; then
	log "Creating ${GAME_DIR}/snakepit/local_settings.py"
	echo  >> "${GAME_DIR}/snakepit/local_settings.py"
	echo "${game_settings}" >> "${GAME_DIR}/snakepit/local_settings.py"
fi

game_onetime_robot_players="$(mdata-get game_onetime_robot_players || echo '')"
if [[ -n "${game_onetime_robot_players}" ]]; then
	log "Switching Snakepit robot service to transient mode"
	svccfg -s robot addpg startd framework
	svccfg -s robot setprop startd/duration = transient
	svccfg -s robot setprop start/timeout_seconds = 0
	svccfg -s robot setprop start/exec = \"/opt/snakepit/bin/run_robot.py --code %{robot/code} %{robot/name}\"
fi

game_robot_players="$(mdata-get game_robot_players | base64 -d)"
if [[ -n "${game_robot_players}" ]]; then
	log "Setting up Snakepit robots"

	echo "${game_robot_players}" | json -ka | while read -r robot_uuid; do
		log "Preparing robot snake ${robot_uuid}"
		robot_name="$(echo "${game_robot_players}" | json "${robot_uuid}")"
		robot_code="${GAME_DIR}/var/run/${robot_uuid}.code"
		robot_xml="/var/tmp/${robot_uuid}.xml"
		robot_user="$(create_robot_user "${robot_uuid}")"

		mdata-get "game_robot_${robot_uuid}_code" | base64 -d > "${robot_code}"
		robot_instance_manifest "${robot_user}" "${robot_uuid}" "${robot_code}" "${robot_name}" > "${robot_xml}"
		svccfg -s svc:/application/robot import "${robot_xml}"
		log "Robot snake svc:/application/robot:${robot_uuid} is ready"
	done
fi

log "Snakepit initialization complete"

svcadm enable main
