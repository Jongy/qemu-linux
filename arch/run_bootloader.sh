#!/bin/bash

# run the VM disk previosly created with make.sh
# start its bootloader

set -e

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 name /path/to/disk"
    exit 1
fi

name="$2"

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 -smp cpus=4 \
    -device virtio-net,netdev=network0 \
    -netdev tap,id=network0,ifname=tap-"$name",script=$DIR/configure_tap_"$name".sh,downscript=$DIR/deconfigure_tap_"$name".sh \
    -drive file="$1",media=disk,format=raw
