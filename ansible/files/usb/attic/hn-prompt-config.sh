#!/usr/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2014, Joyent, Inc.
# Copyright (c) 2016, Erigones, s. r. o.
#

exec 4>>/tmp/prompt-config.log
echo "=== Starting prompt-config on $(tty) at $(date) ===" >&4
export PS4='[\D{%FT%TZ}] $(tty): ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export BASH_XTRACEFD=4
set -o xtrace

PATH=/usr/sbin:/usr/bin
export PATH

. /lib/svc/share/smf_include.sh
. /lib/sdc/config.sh
load_sdc_sysinfo

# Defaults
ntp_hosts="0.sk.pool.ntp.org"
dns_resolver1="8.8.8.8"
dns_resolver2="8.8.4.4"

# Globals
declare -a states
declare -a nics
declare -a assigned
declare DISK_LAYOUT

declare inst_to_hdd
declare TMPROOT

declare root_shadow

declare SYS_ZPOOL
SYS_ZPOOL="zones"
export SYS_ZPOOL

function _begin_header()
{
    printf "%-56s" $1
}

function _end_header()
{
    printf "%s\n" $1
}

sigexit()
{
	echo ""
	echo "System configuration has not been completed."
	echo "You must reboot to re-run system configuration."
	exit 0
}

warning()
{
	echo ""
	echo "WARNING: $*"
	echo ""
}

fatal()
{
	echo ""
	if [[ -n "$1" ]]; then
		echo "ERROR: $1"
	fi
	echo ""
	echo "System configuration failed, launching a shell."
	echo "You must reboot to re-run system configuration."
	echo "A log of setup may be found in /var/log/prompt-config.log"
	echo ""
	/usr/bin/bash
}

ip_to_num()
{
	IP=$1

	OLDIFS=$IFS
	IFS=.
	set -- $IP
	num_a=$(($1 << 24))
	num_b=$(($2 << 16))
	num_c=$(($3 << 8))
	num_d=$4
	IFS=$OLDIFS

	num=$((num_a + $num_b + $num_c + $num_d))
}

num_to_ip()
{
	NUM=$1

	fld_d=$(($NUM & 255))
	NUM=$(($NUM >> 8))
	fld_c=$(($NUM & 255))
	NUM=$(($NUM >> 8))
	fld_b=$(($NUM & 255))
	NUM=$(($NUM >> 8))
	fld_a=$NUM

	ip_addr="$fld_a.$fld_b.$fld_c.$fld_d"
}

#
# Converts an IP and netmask to their numeric representation.
# Sets the global variables IP_NUM, NET_NUM, NM_NUM and BCAST_ADDR to their
# respective numeric values.
#
ip_netmask_to_network()
{
  ip_to_num $1
  IP_NUM=$num

  ip_to_num $2
  NM_NUM=$num

  NET_NUM=$(($NM_NUM & $IP_NUM))

  ip_to_num "255.255.255.255"
  local bcasthost
  bcasthost=$((~$NM_NUM & $num))
  BCAST_ADDR=$(($NET_NUM + $bcasthost))
}

# Tests whether entire string is a number.
isdigit()
{
	[ $# -eq 1 ] || return 1

	case $1 in
		*[!0-9]*|"") return 1;;
		*) return 0;;
	esac
}

# Tests network numner (num.num.num.num)
is_net()
{
	NET=$1

	OLDIFS=$IFS
	IFS=.
	set -- $NET
	a=$1
	b=$2
	c=$3
	d=$4
	IFS=$OLDIFS

	isdigit "$a" || return 1
	isdigit "$b" || return 1
	isdigit "$c" || return 1
	isdigit "$d" || return 1

	[ -z $a ] && return 1
	[ -z $b ] && return 1
	[ -z $c ] && return 1
	[ -z $d ] && return 1

	[ $a -lt 0 ] && return 1
	[ $a -gt 255 ] && return 1
	[ $b -lt 0 ] && return 1
	[ $b -gt 255 ] && return 1
	[ $c -lt 0 ] && return 1
	[ $c -gt 255 ] && return 1
	[ $d -lt 0 ] && return 1
	# Make sure the last field isn't the broadcast addr.
	[ $d -ge 255 ] && return 1
	return 0
}

# EULA
printeula()
{
    eula_file="/mnt/usbkey/eula.txt"

    if [ -f /usbkey/eula.txt ]; then
      eula_file="/usbkey/eula.txt"
    fi

    ${USBMNT}/scripts/pager.sh ${eula_file}
}

prompteula()
{
    local _v

    echo
    promptval "By typing 'accept' you agree with the terms of this software
license agreement, 'reject' to cancel or 'print' to print it again." "print"
    _v=$(echo $val | tr '[:upper:]' '[:lower:]')

    case "$val" in
      "accept")
        :
      ;;
      "print"|"p")
        printeula
        prompteula
      ;;
      "reject"|"cancel")
        echo "EULA was not accepted. The system is going for halt now!"
        sleep 10
        halt
      ;;
      *)
        prompteula
        ;;
    esac
}

# Optional input
promptopt()
{
	val=
	printf "%s [press enter for none]: " "$1"
	read val
}

promptval()
{
	val=""
	def="$2"
	while [ -z "$val" ]; do
		if [ -n "$def" ]; then
			printf "%s [%s]: " "$1" "$def"
		else
			printf "%s: " "$1"
	    fi
	    read val
	    [ -z "$val" ] && val="$def"
	    [ -n "$val" ] && break
	    echo "A value must be provided."
	done
}

# Input must be a valid network number (see is_net())
promptnet()
{
	val=""
	def="$2"
	while [ -z "$val" ]; do
		if [ -n "$def" ]; then
			printf "%s [%s]: " "$1" "$def"
		else
			printf "%s: " "$1"
		fi
		read val
		[ -z "$val" ] && val="$def"
		is_net "$val" || val=""
		[ -n "$val" ] && break
		echo "A valid network number (n.n.n.n) must be provided."
	done
}

printnics()
{
    i=1
    printf "%-6s %-9s %-18s %-7s %-10s\n" "Number" "Link" "MAC Address" \
        "State" "Network"
    while [ $i -le $nic_cnt ]; do
        printf "%-6d %-9s %-18s %-7s %-10s\n" $i ${nics[$i]} \
            ${macs[$i]} ${states[$i]} ${assigned[i]}
        ((i++))
    done
}

# Must choose a valid NIC on this system
promptnic()
{
    if [[ $nic_cnt -eq 1 ]]; then
        val="${macs[1]}"
        return
    fi

    printnics
    num=0
    while [ /usr/bin/true ]; do
        printf "Enter the number of the NIC for the %s interface: " \
           "$1"
        read num
        if ! [[ "$num" =~ ^[0-9]+$ ]] ; then
            echo ""
        elif [ $num -ge 1 -a $num -le $nic_cnt ]; then
            mac_addr="${macs[$num]}"
            assigned[$num]=$1
            break
        fi
        # echo "You must choose between 1 and $nic_cnt."
        updatenicstates
        printnics
    done

    val=$mac_addr
}

promptpw()
{
    while [ /usr/bin/true ]; do
        val=""
        while [ -z "$val" ]; do
            printf "%s: " "$1"
            stty -echo
            read val
            stty echo
            echo
            if [ -n "$val" ]; then
                if [ "$2" == "chklen" -a ${#val} -lt 6 ]; then
                    echo "The password must be at least" \
                        "6 characters long."
                    val=""
                else
                    break
                fi
            else
                echo "A value must be provided."
            fi
        done

        cval=""
        while [ -z "$cval" ]; do
            printf "%s: " "Confirm password"
            stty -echo
            read cval
            stty echo
            echo
            [ -n "$cval" ] && break
            echo "A value must be provided."
        done

        [ "$val" == "$cval" ] && break

        echo "The entries do not match, please re-enter."
    done
}

printdisklayout()
{
  json -f "$1" | json -e '
    out = "  vdevs:\n";
    disklist = [];
    for (var i = 0; i < vdevs.length; i++) {
      var x = vdevs[i];
      if (!x.type) {
        out += "   " + x.name + "\n";
        continue;
      }
      if (x.type === "mirror") {
        out += "   " + x.type + "  " + x.devices[0].name + " " +
          x.devices[1].name + "\n";
        continue;
      }
      out += "   " + x.type + "\n";
      var lout = "      ";
      for (var j = 0; j < x.devices.length; j++) {
        if ((lout + x.devices[j].name).length > 80) {
          out += lout + "\n";
          lout = "      " + x.devices[j].name + " ";
        } else {
          lout += x.devices[j].name + " ";
        }
      }
      out += lout + "\n";
    }
    if (typeof (spares) !== "undefined" && spares.length > 0) {
      out += "  spares:\n";
      var lout = "      ";
      for (var i = 0; i < spares.length; i++) {
        if ((lout + spares[i].name).length > 80) {
          out += lout + "\n";
          lout += "      " + spares[i].name + " ";
        } else {
          lout += spares[i].name + " ";
        }
      }
      out += lout + "\n";
    }
    if (typeof (logs) !== "undefined" && logs.length > 0) {
      out += "  logs:\n";
      var lout = "      ";
      for (var i = 0; i < logs.length; i++) {
        if ((lout + logs[i].name).length > 80) {
          out += lout + "\n";
          lout += "      " + logs[i].name + " ";
        } else {
          lout += logs[i].name + " ";
        }
      }
      out += lout + "\n";
    }
    if (typeof (cache) !== "undefined" && cache.length > 0) {
      out += "  cache:\n";
      var lout = "      ";
      for (var i = 0; i < cache.length; i++) {
        if ((lout + cache[i].name).length > 80) {
          out += lout + "\n";
          lout += "      " + cache[i].name + " ";
        } else {
          lout += cache[i].name + " ";
        }
      }
      out += lout + "\n";
    }
    out += "\n  Total capacity:   " + Number(capacity / 1073741824).toFixed(2)
      + " GB";
    ' out
}

promptpool()
{
  local layout=""
  local disks=

  diskinfo -Hp > /var/tmp/mydisks

  while [[ /usr/bin/true ]]; do

    disklayout -f /var/tmp/mydisks ${layout} > /var/tmp/disklayout.json

    ERR="$(json -f /var/tmp/disklayout.json error)"

    if [[ -n ${ERR} ]] ; then
      warning "${ERR}"
    else
      printf "  ZFS pool layout:\n\n"
      printdisklayout /var/tmp/disklayout.json

      [[ -z "${layout}" ]] && layout="default"

      message="
  This is the '${layout}' storage configuration. To use it, type 'yes'. To see
  a different configuration, type: 'single', 'mirror', 'raidz1', 'raidz2' or
  'default'. To specify a manual configuration, type: 'manual' (recommended
  for advanced users only!).\n\n"
      printf "$message"
    fi

    promptval "Select ZFS pool layout" "default"
    val=$val

    if [[  $val == "single" || \
           $val == "raidz"  || \
           $val == "raidz1" || \
           $val == "raidz2" || \
           $val == "mirror" ]]; then
        if [[ $val == "raidz" ]]; then
          layout="raidz1"
        else
          layout=$val
        fi
    elif [[ $val == "default" ]]; then
      layout=""
    elif [[ $val == "manual" ]]; then
      # let the user manually create the zpool
      DISK_LAYOUT="manual"
      echo ""
      echo "Launching a shell."
      echo "Please manually create a zpool named ${SYS_ZPOOL}."
      echo "If you no longer wish to manually create a zpool,"
      echo "simply exit the shell."
      /usr/bin/bash
      zpool list ${SYS_ZPOOL} >/dev/null 2>/dev/null
      [[ $? -eq 0 ]] && return
    elif [[ $val == "yes" ]]; then
      DISK_LAYOUT=/var/tmp/disklayout.json
      return
    else
      warning "Unknown layout $val"
      layout=""
    fi
  done
}

create_swap()
{
    #
    # We cannot allow the swap size to be less than the size of DRAM, lest
    # we run into the availrmem double accounting issue for locked
    # anonymous memory that is backed by in-memory swap (which will
    # severely and artificially limit VM tenancy).  We will therfore not
    # create a swap device smaller than DRAM -- but we still allow for the
    # configuration variable to account for actual consumed space by using
    # it to set the refreservation on the swap volume if/when the
    # specified size is smaller than DRAM.
    #
    local swapsize
    swapsize=${SYSINFO_MiB_of_Memory}
    zfs create -V ${swapsize}mb ${SWAPVOL} || fatal \
        "failed to create swap partition"

    swap -a /dev/zvol/dsk/${SWAPVOL} > /dev/null 2>&1
}

create_dump()
{
    #
    # Create a dump device zvol on persistent storage.  The dump device is sized at
    # 50% of the available physical memory.  Only kernel pages (so neither ARC nor
    # user data) are included in the dump, and since those pages are compressed
    # using bzip, it's basically impossible for the dump device to be too small.
    #

    local dumpsize
    dumpsize=$(( ${SYSINFO_MiB_of_Memory} / 2 ))

    # Create the dump zvol
    zfs create -V ${dumpsize}mb -o checksum=noparity ${SYS_ZPOOL}/dump || \
        fatal "failed to create the dump zvol"
}

#
# Setup the persistent datasets on the zpool.
#
setup_datasets()
{
  datasets=$(zfs list -H -o name | xargs)

  zfs set atime=off ${SYS_ZPOOL}
  # Create ROOT and default BE
  if [ ${inst_to_hdd} -eq 1 ]; then
	  _begin_header "Transferring image to HDD... "

	  if [ -d ${TMPROOT}/${SYS_ZPOOL} ]; then
		  zfs unmount ${SYS_ZPOOL}
		  rmdir ${TMPROOT}/${SYS_ZPOOL}
	  fi

	  zfs create -o mountpoint=legacy "${SYS_ZPOOL}/${ROOTDS}"
	  _v=`uname -v | sed -e 's|\(.*\)_\(.*\)|\2|'`
	  echo "Creating initial boot environment ${ROOTBE}..."
	  zfs create -o mountpoint=/ "${ROOTBE}"
# Transfer root directory to new ROOTBE
	  echo "Creating HDD boot structure..."

	  _begin_header "Transferring base OS files... "
	  _oldwd=`pwd`
	  cd /
	  (find bin boot dev devices etc kernel lib opt platform root sbin smartdc usr | cpio -pdmu "${TMPROOT}") || \
	  	fatal "Failed to transfer system to HDD"
	  cd "${_oldwd}"
	  echo "done"

	  _begin_header "Creating auxiliary directories... "
	  mkdir -p ${TMPROOT}/system/{boot,contract,object}
 	  mkdir ${TMPROOT}/tmp && chmod 1777 ${TMPROOT}/tmp
	  mkdir ${TMPROOT}/proc
	  mkdir ${TMPROOT}/mnt
	  mkdir ${TMPROOT}/${SYS_ZPOOL}
	  mkdir -p ${TMPROOT}/os > /dev/null 2>/dev/null
	  mkdir -p ${TMPROOT}/platform/i86pc/amd64 > /dev/null 2>/dev/null
	  echo "done"

	  _begin_header "Transferring platform image... "
	  /usr/bin/rsync -a --log-file=/dev/console ${USBMNT}/os/${_v}/platform/i86pc/amd64 ${TMPROOT}/platform/i86pc || \
	  	fatal "Failed to transfer platform image..."
	  echo "done"

	  _begin_header "Mounting default dataset ${SYS_ZPOOL}"
	  # zfs set mountpoint=/${SYS_ZPOOL} ${SYS_ZPOOL} || fatal "failed"
	  zfs mount ${SYS_ZPOOL} > /dev/null 2>/dev/null
	  echo "done"
  fi

  if ! echo $datasets | grep ^${SYS_ZPOOL}/dump > /dev/null; then
    _begin_header "Making dump zvol... "
    create_dump
    _end_header "done"
  fi

  if ! echo $datasets | grep ${CONFDS} > /dev/null; then
    _begin_header "Initializing config dataset for zones... "
    zfs create -o mountpoint=/config ${CONFDS} || fatal "failed to create the config dataset"
    cp -p ${TMPROOT}/etc/zones/* ${TMPROOT}/config
	zfs set mountpoint=legacy ${CONFDS}
    _end_header "done"
  fi

  if ! echo $datasets | grep ${USBKEYDS} > /dev/null; then
      _begin_header "Creating config dataset... "
      zfs create -o mountpoint=legacy -o compression=lz4 ${USBKEYDS} || \
        fatal "failed to create the config dataset"
      mkdir /usbkey > /dev/null 2>/dev/null
      mount -F zfs ${USBKEYDS} /usbkey
      _end_header "done"
  fi

  if ! echo $datasets | grep ${COREDS} > /dev/null; then
    _begin_header "Creating global cores dataset... "
    zfs create -o quota=10g -o mountpoint=/${SYS_ZPOOL}/global/cores \
        -o compression=gzip ${COREDS} || \
        fatal "failed to create the cores dataset"
    _end_header "done"
  fi

  if ! echo $datasets | grep ${OPTDS} > /dev/null; then
    _begin_header "Creating opt dataset... "
    zfs create -o mountpoint=legacy ${OPTDS} || \
      fatal "failed to create the opt dataset"
    _end_header "done"
  fi

  if ! echo $datasets | grep ${VARDS} > /dev/null; then
    _begin_header "Initializing var dataset... "
    _vardest="/${VARDS}"
    [ ${inst_to_hdd} -eq 1 ] && _vardest="/var"

    zfs create -o mountpoint=${_vardest} ${VARDS} || \
      fatal "failed to create the var dataset"
    chmod 755 ${TMPROOT}/${_vardest}

    mkdir -p /var/log
    trap "cp /tmp/prompt-config.log ${TMPROOT}/var/log/prompt-config.log" EXIT

    cd /var
    if ( ! find . -print | cpio -pdm ${TMPROOT}/${_vardest} 2>/dev/null ); then
        fatal "failed to initialize the var directory"
    fi

    [ ${inst_to_hdd} -eq 0 ] && zfs set mountpoint=legacy ${VARDS}
	zfs set canmount=noauto ${VARDS}

    _end_header "done"
  fi

  if ! echo $datasets | grep ${SWAPVOL} > /dev/null; then
    _begin_header "Creating swap zvol..."
    create_swap
    _end_header "done"
  fi

  if ! echo $datasets | grep ${BACKUPDS} > /dev/null; then
    _begin_header "Creating backup dataset... "
    zfs create ${BACKUPDS} || \
      fatal "failed to create the backup dataset"
    zfs create -o compression=lz4 ${BACKUPDS}/file || \
      fatal "failed to create file backup dataset"
    zfs create -o compression=lz4 ${BACKUPDS}/ds || \
      fatal "failed to create dataset backup dataset"
    _end_header "done"
  fi

  if ! echo $datasets | grep ${ISODS} > /dev/null; then
    _begin_header "Creating ISO dataset... "
    zfs create -o mountpoint=/iso ${ISODS} || \
      fatal "failed to create the ISO dataset"
    zfs set atime=on ${ISODS} || \
      fatal "failed to set atime=on for ${ISODS}"
    _end_header "done"
  fi

  #
  # Since there may be more than one storage pool on the system, put a
  # file with a certain name in the actual "system" pool.
  #
  touch ${TMPROOT}/${SYS_ZPOOL}/.system_pool

  if [ ${inst_to_hdd} -eq 1 ]; then
	  _begin_header "Transferring USB dongle contents to HDD... "
	  /usr/bin/rsync -a ${USBMNT}/ /usbkey || \
	  	fatal "Failed to transfer"
	  _end_header "done"
	  _begin_header "Activating boot environment ${DEFBE}... "
	  /usr/sbin/beadm activate ${DEFBE} || \
	  	fatal "Failed to activate"
	  _end_header "done"
	  echo 'boot-args="-B smartos=true,headnode=true"' >> ${TMPROOT}/boot/loader.conf
	  echo "7.0" > ${TMPROOT}/.smartdc_version

	  # Set root shadow
      sed -e "s|^root:[^\:]*:|root:${root_shadow}:|" ${TMPROOT}/etc/shadow > ${TMPROOT}/etc/shadow.new \
      && chmod 400 ${TMPROOT}/etc/shadow.new \
      && mv ${TMPROOT}/etc/shadow.new ${TMPROOT}/etc/shadow
  fi
}

create_zpool()
{
  local pool=$1
  local layout=$2

  # If the pool already exists, don't create it again.
  if /usr/sbin/zpool list -H -o name ${pool} >/dev/null 2>/dev/null; then
    printf "%-56s\n" "Pool '${pool}' exists, skipping creation..."
    return 0
  fi

  _begin_header "Creating pool ${pool}... "

  # If this is not a manual layout, then we've been given
  # a JSON file describing the desired pool, so use that:
  _rpoolarg=""
  if [ ${inst_to_hdd} -eq 1 ]; then
	  _rpoolarg="-R ${TMPROOT}"
  fi

  mkzpool -f ${_rpoolarg} ${pool} ${layout} || \
	fatal "failed to create pool ${pool}"

  zfs set atime=off ${pool} || \
      fatal "failed to set atime=off for pool ${pool}"

  _end_header "done"
}

create_zpools()
{
  local layout=$1
  export TMPROOT=""

  export VARDS=${SYS_ZPOOL}/var
  export DEFBE=dcos-1
  export ROOTDS=ROOT
  export ROOTBE=${SYS_ZPOOL}/${ROOTDS}/${DEFBE}

  if [ ${inst_to_hdd} -eq 1 ]; then
	  export VARDS="${ROOTBE}/var"
	  export TMPROOT="/.a"
	  mkdir -p "${TMPROOT}" > /dev/null 2>/dev/null
  fi

  create_zpool ${SYS_ZPOOL} ${layout}
  sleep 2

  svccfg -s svc:/system/smartdc/init setprop config/zpool="${SYS_ZPOOL}"
  svccfg -s svc:/system/smartdc/init:default refresh

  export BACKUPDS=${SYS_ZPOOL}/backups
  export CONFDS=${SYS_ZPOOL}/config
  export COREDS=${SYS_ZPOOL}/cores
  export ISODS=${SYS_ZPOOL}/iso
  export OPTDS=${SYS_ZPOOL}/opt
  export USBKEYDS=${SYS_ZPOOL}/usbkey
  export SWAPVOL=${SYS_ZPOOL}/swap

  setup_datasets

}

updatenicstates()
{
    states=(1)
    #states[0]=1
    while IFS=: read -r link state ; do
        states=( ${states[@]-} $(echo "$state") )
    done < <(dladm show-phys -po link,state 2>/dev/null)
}

printheader()
{
  local newline=
  local cols=`tput cols`
  local subheader=$1

  if [ $cols -gt 80 ] ;then
    newline='\n'
  fi

  clear
  for i in {1..80} ; do printf "-" ; done && printf "$newline"
  printf " %-40s\n" "Danube Cloud Setup"
  printf " %-40s%38s\n" "$subheader" "https://docs.danubecloud.org"
  for i in {1..80} ; do printf "-" ; done && printf "$newline"

}

USBMNT=$1

trap sigexit SIGINT

#
# Get local NIC info
#
nic_cnt=0

while IFS=: read -r link addr ; do
    ((nic_cnt++))
    nics[$nic_cnt]=$link
    macs[$nic_cnt]=`echo $addr | sed 's/\\\:/:/g'`
    assigned[$nic_cnt]="-"
done < <(dladm show-phys -pmo link,address 2>/dev/null)

if [[ $nic_cnt -lt 1 ]]; then
    echo "ERROR: cannot configure the system, no NICs were found."
    exit 0
fi

ifconfig -a plumb
updatenicstates

export TERM=xterm-color
stty erase ^H

printheader "Danube Cloud"

message="
You must answer the following questions to configure the system.
You will have a chance to review and correct your answers, as well as a
chance to edit the final configuration, before it is applied.

Would you like to continue with configuration? [Y/n] "

printf "$message"
read continue;
if [[ $continue == 'n' ]]; then
    exit 0
fi

export inst_to_hdd=0

printheader "EULA"
printeula
prompteula

#
# Main loop to prompt for user input
#
while [ /usr/bin/true ]; do
	printheader "Datacenter Information"
	message="
  The following questions will ask a few information about your datacenter
  and Danube Cloud installation.\n\n"
    printf "$message"

    promptval "Enter DC name"
    datacenter_name="$val"

    printheader "Networking - Admin"
    message="
  The admin network is used for management purposes and communication between
  the compute nodes and headnode in Danube Cloud. This network is supposed to
  be used for provisioning new compute nodes and there are several application
  zones which are assigned sequential IP addresses on this network. It is very
  important that this network is used exclusively for Danube Cloud management
  only.\n\n"
    printf "$message"

    promptnic "'admin'"
    admin_nic="$val"

    valid=0
    while [ $valid -ne 1 ]; do
        promptnet "(admin) headnode IP address" "$admin_ip"
        admin_ip="$val"

        [[ -z "$admin_netmask" ]] && admin_netmask="255.255.255.0"

        promptnet "(admin) headnode netmask" "$admin_netmask"
        admin_netmask="$val"

        ip_netmask_to_network "$admin_ip" "$admin_netmask"
        [ $IP_NUM -ne $BCAST_ADDR ] && valid=1
    done

    ip_netmask_to_network "$admin_ip" "$admin_netmask"
    num_to_ip $NET_NUM
    admin_network="$ip_addr"

    printheader "Networking - Continued"

    message=""
    printf "$message"

    message="
  The default gateway will determine which router will be used to connect this
  node to other networks. This will almost certainly be the router connected
  to your 'admin' network.\n\n"
    printf "$message"

    promptnet "Enter the default gateway IP" "$headnode_default_gateway"
    headnode_default_gateway="$val"

    promptval "Enter the Primary DNS server IP" "$dns_resolver1"
    dns_resolver1="$val"
    promptval "Enter the Secondary DNS server IP" "$dns_resolver2"
    dns_resolver2="$val"
    promptval "Enter the domain name" "$domainname"
    domainname="$val"
    promptval "Default DNS search domain" "$dns_domain"
    dns_domain="$val"

    printheader "Web Management"
    message="
  The IP address set here will host the web administration portal of your
  Danube Cloud installation. This IP address will also be used as a basis
  for enumerating other Danube Cloud administrative zones networking.\n\n"
    printf "$message"

    ip_netmask_to_network "$admin_ip" "$admin_netmask"
    next_addr=$(($IP_NUM + 1))
    num_to_ip $next_addr

    promptnet "Management IP address" "$ip_addr"
    mgmt_admin_ip="$val"

    printheader "System Configuration"
    message="
  Setup will now go through and prompt for final pieces of account
  configuration. This includes setting the root password for the
  global zone and optionally setting a hostname.\n\n"
    printf "$message"

    promptpw "Enter root password" "nolen"
    root_shadow="$val"

    promptval "Enter system hostname" "headnode.$domainname"
    hostname="$val"

    printheader "Storage"
    message="
  Setup will automatically determine what we think is the best ZFS pool layout
  based on your current disk setup. You may use this suggestion, change to
  another storage profile or simply create your own configuration manually.\n\n"
    printf "$message"

    promptpool

	printheader "Administrator's e-mail address"

	message=""
	printf "$message"

	message="
  Administrator's e-mail address which will receive messages generated by system.\n\n"
	printf "$message"

	promptval "Enter administrator's e-mail address" "admin@example.com"
	admin_email="${val}"

	clear
	printheader "Configuration master password"
	message=""
	printf "$message"

	message="
  Please choose a password that will protect your Danube Cloud data center
  configuration settings. This password will be required whenever you
  install an additional compute node into your data center.
  
  PLEASE KEEP THIS PASSWORD SAFE AND CONFIDENTIAL!\n\n"
	printf "$message"

	esdc_install_password=""

	while [[ -z "${esdc_install_password}" ]]; do
		promptpw "Enter configuration password" "chklen"
		esdc_install_password="${val}"
	done

    printheader "Installation to disk"
	message=""
	printf "${message}"

    promptval "Install to HDD instead of booting from USB?" "n"
    [ "$val" == "y" ] && export inst_to_hdd=1

	printheader "Verify Configuration"
	message=""

	printf "$message"

	echo "Verify that the following values are correct:"
	echo ""
	echo "Datacenter name: $datacenter_name"
	echo "MAC address: $admin_nic"
	echo "IP address: $admin_ip"
	echo "Netmask: $admin_netmask"
	echo "Gateway router IP address: $headnode_default_gateway"
	echo "DNS servers: $dns_resolver1,$dns_resolver2"
	echo "Domain name: $domainname"
	echo "Default DNS search domain: $dns_domain"
	echo "Hostname: $hostname"
	echo "NTP server: $ntp_hosts"
	echo "Management portal IP address: $mgmt_admin_ip"
	echo "Administrator's e-mail: ${admin_email}"
	echo ""
	tohdd="No"
	[ ${inst_to_hdd} -eq 1 ] && tohdd="Yes"
	printf "Install to HDD: %s\n" "${tohdd}"

    promptval "Is this correct?" "y"
    [ "$val" == "y" ] && break
    clear
done

# Calculate admin network
ip_netmask_to_network "$admin_ip" "$admin_netmask"
num_to_ip $NET_NUM
admin_network="$ip_addr"

# Calculate admin network address for every core zone.
ip_netmask_to_network "$mgmt_admin_ip" "$admin_netmask"

next_addr=$(($IP_NUM + 1))
num_to_ip "$next_addr"
mon_admin_ip="$ip_addr"

next_addr=$(($next_addr + 1))
num_to_ip "$next_addr"
dns_admin_ip="$ip_addr"

next_addr=$(($next_addr + 1))
num_to_ip "$next_addr"
img_admin_ip="$ip_addr"

next_addr=$(($next_addr + 1))
num_to_ip "$next_addr"
cfgdb_admin_ip="$ip_addr"

#
# Generate config file
#
tmp_config=/tmp_config
touch $tmp_config
chmod 600 $tmp_config

root_shadow=$(/usr/lib/cryptpass "$root_shadow")
cat > ${tmp_config} << EEOOFF
#
# This file was auto-generated and must be source-able by bash.
#
# admin_nic is the nic admin_ip will be connected to for headnode zones.
admin_nic=$admin_nic
admin_ip=$admin_ip
admin_netmask=$admin_netmask
admin_network=$admin_network
admin_gateway=$admin_ip

headnode_default_gateway=$headnode_default_gateway

dns_resolvers=$dns_resolver1,$dns_resolver2
dns_domain=$dns_domain

ntp_hosts=$ntp_hosts
compute_node_ntp_hosts=$admin_ip

datacenter_name=$datacenter_name
hostname=$hostname

# Danube Cloud core zone variables
mgmt_admin_ip=$mgmt_admin_ip

mon_admin_ip=$mon_admin_ip

dns_admin_ip=$dns_admin_ip

img_admin_ip=$img_admin_ip

cfgdb_admin_ip=$cfgdb_admin_ip

# This is the entry from /etc/shadow for root
root_shadow='${root_shadow}'

admin_email=${admin_email}
esdc_install_password=${esdc_install_password}
EEOOFF

clear
create_zpools "$DISK_LAYOUT"

if [ ${inst_to_hdd} -eq 0 ]; then
	cp -f ${tmp_config} ${USBMNT}/config
fi
cp -f ${tmp_config} /usbkey/config

sync
sleep 1

cat << EEOOFF
The system will now finish configuration and reboot in 10 seconds. Please wait..."

EEOOFF

[ ${inst_to_hdd} -eq 1 ] && echo "!!! PLEASE REMOVE THE USB DONGLE !!!"

sync
sleep 10
reboot
