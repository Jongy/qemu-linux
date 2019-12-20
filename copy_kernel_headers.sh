#!/bin/bash
# this script copies files necessary for module building from the linux source directory to a separate, clean
# directory.
# (the outputs should match what you get in "linux-headers-" packages in OS distros)


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 linux_source_dir kernel_headers_dir"
    exit 1
fi

linux_source_dir=$(realpath $1)
kernel_headers_dir=$(realpath $2)

if [ ! -d "$kernel_headers_dir" ]; then
    mkdir -p "$kernel_headers_dir"
fi

# what do you copy: I based this on what I saw my Arch /lib/modules/../build directory has.

# all Kconfig & Makefile files. this overrides the simple makefile for kernel compilation only
# that's created in the target directory when you compile with make O=...
pushd "$linux_source_dir";
    # both 'cp' and 'rsync' can't be used to easily copy parent directories when not existing :/
    find * -type d -exec mkdir -p "$kernel_headers_dir/{}" \;
    find * -name Kconfig -exec cp {} "$kernel_headers_dir"/{} \;
    find * -name Makefile -exec cp {} "$kernel_headers_dir"/{} \;
popd;

# copy the entire scripts/ directory
cp -r "$linux_source_dir"/scripts/ "$kernel_headers_dir"/

# copy the entire include/ directory
cp -r "$linux_source_dir"/include/ "$kernel_headers_dir"/

# copy the entire include/ directory for the arch. since I work on x86 I don't
# mind hard-coding it here
cp -r "$linux_source_dir"/arch/x86/include/ "$kernel_headers_dir"/arch/x86/

echo
echo "Done! You can now build with KDIR=$kernel_headers_dir"
