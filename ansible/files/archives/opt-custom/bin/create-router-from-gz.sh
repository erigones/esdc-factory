#!/usr/bin/bash

set -e

ARG="$1"

IPFCONF=/etc/ipf/ipf.conf
IPNATCONF=/etc/ipf/ipnat.conf
# shellcheck disable=SC1091
. /usbkey/config

if [[ "$(/usr/bin/zonename)" != "global" ]]; then
	echo "Must be run in global zone!"
	exit 1
fi

if	[[ "$(cksum "${IPFCONF}" | cut -d' ' -f1)" != "4114956902" ]] || 
	[[ -f "${IPNATCONF}" ]]; then
	if [[ "${ARG}" != "-f" ]]; then
		echo "Firewall configuration in /etc/ipf is not factory default."
		echo "Not doing anything."
		echo "Override by adding \"-f\""
		exit 2
	fi
fi


GetIfFromNicTag() {
	local tag="$1"
	nictagadm list -p -d '|' | awk -F'|' '/^'"${tag}"'\|/ {print $3}'
}

GetSubnetFromNic() {
	local nic="$1"
	ipadm show-addr -o addrobj,addr | awk '/^'"${nic}"'\// {print $2}'
}

cat << EOF

This script will configure the global zone to route and NAT outgoing traffic
from "admin" subnet to "external" interface.
Operations:
- write ${IPFCONF}
- write ${IPNATCONF}
- reload firewall
- enable IPv4 forwarding
- persist the configuration

The configuration is not persistent accross reboots.
It is recommended only for testing purposes!

Press Ctrl+C for quit or any other key to continue.
EOF
read -r

ADM_IF="$(GetIfFromNicTag admin)"
ADM_NET="$(GetSubnetFromNic "${ADM_IF}")"
if [[ -z "${ADM_NET}" ]]; then
	# try other way if necessary
	ADM_IF="admin0"
	ADM_NET="$(GetSubnetFromNic "admin0")"
fi
if [[ -z "${ADM_NET}" ]]; then
	echo "ERROR: Cannot find admin subnet"
	exit 5
fi

EXT_IF="external0"
if ! ipadm show-addr | grep -q external0/; then
	echo "No external interface found!"
	exit 3
fi
EXT_IP="$(GetSubnetFromNic external0 | cut -d/ -f1)"

cat > "${IPFCONF}" << EOF
# Allow loopback.
pass in quick on lo0
pass out quick on lo0

# Allow everything passing via VPN interface.
pass in quick on tun0
pass out quick on tun0

pass out quick on ${EXT_IF} keep state

# Allow only selected sources:

#pass in quick on rge0 from x.x.x.x/32 to any keep state

#block in quick on ${EXT_IF}
EOF

# shellcheck disable=SC2154
cat > "${IPNATCONF}" << EOF

map ${EXT_IF} ${ADM_NET} -> 0/32

# Redir to internal services:
## mgmt01
#rdr ${EXT_IF} from any to ${EXT_IP}/32 port = 80 -> ${mgmt_admin_ip} port 80 tcp
#rdr ${EXT_IF} from any to ${EXT_IP}/32 port = 443 -> ${mgmt_admin_ip} port 443 tcp
## dns01
#rdr ${EXT_IF} from any to ${EXT_IP}/32 port = 53 -> ${dns_admin_ip} port 53 tcp/udp
#rdr ${ADM_IF} from any to any port = 53 -> ${dns_admin_ip} port 53 tcp/udp
## mon01
#rdr ${EXT_IF} from any to ${EXT_IP}/32 port = 444 -> ${mgmt_admin_ip} port 443 tcp
## cfgdb01
#rdr ${EXT_IF} from any to ${EXT_IP}/32 port = 12181 -> ${cfgdb_admin_ip} port 12181 tcp
EOF

svcadm enable ipfilter
svcadm refresh ipfilter

routeadm -ue ipv4-forwarding

# Persist the configuration
cp "${IPFCONF}" /opt/custom/etc/ipf.d/ipf.conf-050
cp "${IPNATCONF}" /opt/custom/etc/ipf.d/ipnat.conf-050

cat > /opt/custom/etc/rc-pre-vmadmd.d/050-enable-routing.sh << EOF
set -e 

. /lib/svc/share/smf_include.sh

start() {
    routeadm -ue ipv4-forwarding
}

stop() {
    routeadm -ud ipv4-forwarding
}

case "\$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	refresh)
		#refresh
		exit \$SMF_EXIT_OK
		;;
	*)
		echo "Usage: $0 {start|stop|refresh}"
		exit \$SMF_EXIT_ERR_CONFIG
esac

exit \$SMF_EXIT_OK
EOF
chmod +x /opt/custom/etc/rc-pre-vmadmd.d/050-enable-routing.sh

echo "Done"
echo "Update default routes in VMs if necessary"
