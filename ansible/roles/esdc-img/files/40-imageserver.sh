#!/bin/bash

SHIPMENT_USER=shipment
SHIPMENT_GROUP=shipment

ZONENAME=$(zonename)

log "Creating and configuring /datasets"

if [[ -d /zones/${ZONENAME}/data ]]; then

        zfs set mountpoint=/datasets zones/${ZONENAME}/data
else
        mkdir -p /datasets
fi

chown -R ${SHIPMENT_USER}:${SHIPMENT_GROUP} /datasets
