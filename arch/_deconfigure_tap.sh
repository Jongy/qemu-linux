#!/bin/bash

set -e

if [[ "$#" -ne 1 ]]; then
    echo "$0 tap_name"
    exit 1
fi

brctl delif br-vms "$1"
ip link set dev "$1" down
