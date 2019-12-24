#!/bin/bash

# create a new VM
# follow the arch installation settings, basically.

set -e

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 /path/to/disk /path/to/installer.iso"
    exit 1
fi

qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -device virtio-net,netdev=network0 \
    -netdev tap,id=network0,ifname=tap-arch,script=configure_tap_arch.sh,downscript=deconfigure_tap_arch.sh \
    -drive file=$1,media=disk,format=raw -drive file=$2,media=cdrom
