#!/bin/bash
set -e

if [ $# != 1 ]; then
    echo "usage: $0 /path/to/kernel"
    exit 1
fi

TAP_NAME=tap-qemu

if [ ! -d /sys/class/net/$TAP_NAME ] ; then
    echo "Run 'sudo $(dirname $0)/configure_tap_qemu.sh' first"
    exit 1
fi

if [ $EUID -eq 0 ]; then
    echo "Don't run me as root/with sudo!"
    exit 1
fi

mkdir -p fs
[[ -f ./update_fs.sh ]] && ./update_fs.sh

fallocate -l 30M ext4
mkfs.ext4 -F ext4 -d fs

if [ -d "$1" ]; then
    kernel="$1/arch/x86/boot/bzImage"
else
    kernel="$1"
fi

qemu-system-x86_64 \
    -kernel "$kernel" \
    -enable-kvm \
    -initrd initramfs.cpio.gz \
    -nographic -append "nokaslr console=ttyS0" \
    -drive file=ext4,format=raw \
    -netdev tap,id=net0,ifname=$TAP_NAME,script=no,downscript=no \
    -device e1000,netdev=net0
