#!/bin/bash

# create a new VM
# follow the arch installation settings, basically.

set -e

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 /path/to/disk name /path/to/installer.iso"
    exit 1
fi

name="$2"

qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 -smp cpus=4  \
    -device virtio-net,netdev=network0 \
    -netdev tap,id=network0,ifname=tap-"$name",script=configure_tap_"$name".sh,downscript=deconfigure_tap_"$name".sh \
    -drive file="$1",media=disk,format=raw -drive file="$3",media=cdrom -boot d
