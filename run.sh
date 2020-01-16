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

initramfs="initramfs.cpio.gz"
kernel_dir=$(dirname "$1")
if [ -e "$kernel_dir"/lib_modules ]; then
    # it has a modules directory. this is used when we really need the modules
    # to be loaded, e.g on centos which has e1000 as a module and not a built in.

    # make new one if it doesn't have
    if [ ! -f "$kernel_dir"/initramfs.cpio.gz ]; then
        ./make_initramfs.sh "$kernel_dir"/initramfs.cpio.gz "$kernel_dir"/lib_modules
    fi

    initramfs="$kernel_dir"/initramfs.cpio.gz
fi

# TODO enable virtio. or not? e1000 is easier.

qemu-system-x86_64 \
    -kernel "$kernel" \
    -enable-kvm \
    -smp cpus=4 \
    -initrd "$initramfs" \
    -nographic -append "nokaslr console=ttyS0" \
    -drive file=ext4,format=raw \
    -netdev tap,id=net0,ifname=$TAP_NAME,script=no,downscript=no \
    -device e1000,netdev=net0
