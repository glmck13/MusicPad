#!/bin/bash

BLUETOOTH_DIR=/var/lib/bluetooth

endpoint=$(bluetoothctl endpoint.list)

if [ ! "$endpoint" ]; then

for CONTROLLER_DIR in ${BLUETOOTH_DIR}/*; do
  CONTROLLER_MAC=${CONTROLLER_DIR##*/}
  if [ -d "${CONTROLLER_DIR}" ] && [[ $CONTROLLER_MAC =~ ^([0-9A-F]{2}[:]){5}([0-9A-F]{2})$ ]] ; then
    for DEVICE_DIR in ${CONTROLLER_DIR}/*; do
      DEVICE_MAC=${DEVICE_DIR##*/}
      if [ -d "${DEVICE_DIR}" ] && [[ $DEVICE_MAC =~ ^([0-9A-F]{2}[:]){5}([0-9A-F]{2})$ ]] ; then
        if grep "Trusted=true" ${DEVICE_DIR}/info > /dev/null ; then
          echo -e "select ${CONTROLLER_MAC}\nconnect ${DEVICE_MAC}\nquit" | bluetoothctl
        fi
      fi
    done
  fi
done

fi
