#!/bin/bash

. /lib/sdc/usb-key.sh

unmount_usb_key

[ $? -eq 0 ] && echo "USB key unmounted"

