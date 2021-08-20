#!/bin/sh

if [ "$(virt-what | tail -1)" != "bhyve" ]; then
	echo Bhyve hypervisor was not detected. Exiting.
	exit 0
fi

echo Starting qemu-ga on COM3...
qemu-ga --method=virtio-serial --path=/dev/ttyS2 -vvv -F/etc/qemu-ga/fsfreeze-hook

