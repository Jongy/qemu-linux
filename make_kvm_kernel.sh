#!/bin/bash
# builds a kernel with configuration for kvm plus any features I like for development
set -e

if [[ "$#" -ne 4 && "$#" -ne 5 ]]; then
    echo "Usage: $0 linux_source_dir kernels_dir version base_config (alldefconfig/x86_64_defconfig) [CC]"
    exit 1
fi

patch_kernel_sources=$(realpath $(dirname $0)/patch_kernel_sources.sh)
copy_kernel_headers=$(realpath $(dirname $0)/copy_kernel_headers.sh)

linux_source_dir=$(realpath $1)
mkdir -p "$2"
kernels_dir=$(realpath $2)
version="$3"
base_config="$4"

if [ "$#" -eq 5 ]; then
    cc="$5"
else
    cc="gcc"
fi

case "$base_config" in
    alldefconfig|x86_64_defconfig) ;;
    *) echo "Bad base config \"$base_config\"! Select alldefconfig / x86_64_defconfig"
       exit 1
       ;;
esac

kernel_dir=$(realpath "$kernels_dir"/"$version"_"$base_config"_kvmconfig)

mkdir -p "$kernels_dir"

pushd "$linux_source_dir"

git checkout "$version"

"$patch_kernel_sources" .

echo
echo "Please check $(pwd) and fix all possible conflicts, then continue"
echo
read

function enable_config() {
    ./scripts/config --file "$kernel_dir/.config" -e $1
}

mkdir -p "$kernel_dir"
make CC="$cc" O="$kernel_dir" "$base_config"

if [ "$base_config" == "alldefconfig" ]; then
    # for the /fs partition
    enable_config EXT4_FS

    enable_config MODULES
    enable_config MODULES_UNLOAD

    # for gzip initramfs
    enable_config BLK_DEV_INITRD
    enable_config RD_GZIP
    enable_config INITRAMFS_COMPRESSION_GZIP
fi

if ! make CC="$cc" O="$kernel_dir" kvmconfig ; then
    echo
    echo "make kvmconfig failed, perhaps it's missing in current kernel version"
    echo "check and continue when ready"
    read
fi

# debugging stuff
enable_config KPROBES
enable_config FTRACE
enable_config FUNCTION_TRACER
enable_config KALLSYMS_ALL

# select new defaults after more options trees have been opened
make CC="$cc" O="$kernel_dir" olddefconfig

build_cmd="make CC="$cc" O="$kernel_dir" -j 8"
echo "running build: $build_cmd"
$build_cmd

"$copy_kernel_headers" "$linux_source_dir" "$kernel_dir"

popd
