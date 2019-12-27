#!/bin/bash

TAP_NAME=tap-qemu

if [ -d /sys/class/net/$TAP_NAME ] ; then
    echo "$TAP_NAME exists, nothing to do"
    exit 0
fi

if [ $EUID -ne 0 ] || [ "$SUDO_USER" == "root" ]; then
    echo "Run me with sudo!"
    exit 1
fi

tunctl -u $SUDO_USER -t $TAP_NAME

ip addr add 10.1.0.1/24 dev $TAP_NAME
ip link set dev $TAP_NAME up
