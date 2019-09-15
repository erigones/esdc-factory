#!/bin/bash

. /lib/sdc/usb-key.sh

usbmnt="$(mount_usb_key)"

echo "USB key mounted at ${usbmnt}"

