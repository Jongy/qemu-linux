#!/bin/bash
set -e

if [ $# != 1 ]; then
    echo "usage: $0 /path/to/kernel"
    exit 1
fi

mkdir -p fs
[[ -f ./update_fs.sh ]] && ./update_fs.sh

fallocate -l 30M ext4
mkfs.ext4 -F ext4 -d fs

sudo qemu-system-x86_64 \
    -kernel "$1" \
    -enable-kvm \
    -initrd initramfs.cpio.gz \
    -nographic -append "nokaslr console=ttyS0" \
    -drive file=ext4,format=raw \
    -netdev tap,id=net0,ifname=tap-qemu,script=configure_tap_qemu.sh,downscript=no \
    -device e1000,netdev=net0
