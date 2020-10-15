#!/bin/bash

set -e

if [[ "$#" -ne 1 ]]; then
    echo "$0 tap_name"
    exit 1
fi

./_make_bridge.sh

brctl addif br-vms "$1"
ip link set dev "$1" up
