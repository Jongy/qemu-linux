#!/bin/bash
set -e

if [ $# -ge 1 ]; then
    output=$(realpath $1)
else
    output=$(realpath initramfs.cpio.gz)
fi

if [ $# -eq 2 ]; then
    lib_modules=$(realpath "$2")
fi

if [ $# -ge 3 ]; then
    echo "usage: $0 [output [lib/modules directory]]"
    exit 1
fi

pushd initramfs

# other directories are tracked by git because they are populated.
mkdir -p {dev,etc,lib,proc,sbin,sys,fs}

if [ ! -f bin/busybox ]; then
    echo "Busybox not found, downloading..."
    wget -O bin/busybox https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
    chmod +x bin/busybox
fi

if [ ! -z "$lib_modules" ]; then
    cp -r "$lib_modules" lib/modules
fi

find -print0 | cpio --null -ov --format=newc | gzip -9 > "$output"

if [ ! -z "$lib_modules" ]; then
    rm -r lib/modules
fi

popd

echo
echo "initramfs ready at $output"
