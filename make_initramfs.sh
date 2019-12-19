OUTPUT=initramfs.cpio.gz

pushd initramfs

# other directories are tracked by git because they are populated.
mkdir -p {dev,etc,lib,proc,sbin,sys,fs}

echo "Requesting sudo for initramfs /dev/sda"
sudo mknod dev/sda b 8 0

if [ ! -f bin/busybox ]; then
    echo "Busybox not found, downloading..."
    wget -O bin/busybox https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
    chmod +x bin/busybox
fi

find -print0 | cpio --null -ov --format=newc | gzip -9 > ../$OUTPUT

popd

echo
echo "initramfs ready at $OUTPUT"
