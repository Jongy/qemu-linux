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

QEMU_OPTS="-kernel $1"
QEMU_OPTS="$QEMU_OPTS -enable-kvm"
QEMU_OPTS="$QEMU_OPTS -initrd initramfs.cpio.gz"
QEMU_OPTS="$QEMU_OPTS -nographic -append \"console=ttyS0\""
QEMU_OPTS="$QEMU_OPTS -drive file=ext4,format=raw"

QEMU_OPTS="$QEMU_OPTS -netdev tap,id=net0,ifname=tap-qemu,script=configure_tap_qemu.sh,downscript=no"
QEMU_OPTS="$QEMU_OPTS -device e1000,netdev=net0"

echo "QEMU opts: $QEMU_OPTS"
sudo qemu-system-x86_64 $QEMU_OPTS
