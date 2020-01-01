#!/bin/bash

# run the VM disk previosly created with make.sh

set -e

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 name /path/to/disk"
    exit 1
fi

name="$1"

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

TMPMOUNT=$DIR/.tmpmount
mkdir -p $TMPMOUNT

mount -o ro "$2" $TMPMOUNT

(sleep 3; umount $TMPMOUNT)&

kernel=$(echo $TMPMOUNT/boot/vmlinuz-*)
echo "using kernel $kernel"
[ -f $TMPMOUNT/boot/initrd* ] && initrd=$(echo $TMPMOUNT/boot/initrd*)
[ -f $TMPMOUNT/boot/initramfs-linux.img ] && initrd=$TMPMOUNT/boot/initramfs-linux.img
echo "using initrd $initrd"

qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 -smp cpus=4 \
    -device virtio-net,netdev=network0 \
    -netdev tap,id=network0,ifname=tap-"$name",script=$DIR/configure_tap_"$name".sh,downscript=$DIR/deconfigure_tap_"$name".sh \
    -drive file="$2",media=disk,format=raw \
    -kernel "$kernel" -initrd "$initrd" \
    -append "console=ttyS0 root=/dev/sda nokaslr" -nographic
