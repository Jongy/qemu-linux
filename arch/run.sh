#!/bin/bash

# run the VM disk previosly created with make.sh

set -e

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 /path/to/disk"
    exit 1
fi

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

TMPMOUNT=$DIR/.tmpmount
mkdir -p $TMPMOUNT

mount "$1" $TMPMOUNT

(sleep 10; umount $TMPMOUNT)&

qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 -smp cpus=4\
    -device virtio-net,netdev=network0 \
    -netdev tap,id=network0,ifname=tap-arch,script=$DIR/configure_tap_arch.sh,downscript=$DIR/deconfigure_tap_arch.sh \
    -drive file=$1,media=disk,format=raw \
    -kernel $TMPMOUNT/boot/vmlinuz-linux -initrd $TMPMOUNT/boot/initramfs-linux.img \
    -append "console=ttyS0 root=/dev/sda nokaslr" -nographic
