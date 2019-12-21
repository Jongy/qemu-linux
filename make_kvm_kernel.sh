#!/bin/bash
# builds a kernel with configuration for kvm plus any features I like for development
set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 linux_source_dir kernels_dir version"
    exit 1
fi

patch_kernel_sources=$(realpath $(dirname $0)/patch_kernel_sources.sh)

linux_source_dir=$(realpath $1)
kernels_dir=$(realpath $2)
version=$3

kernel_dir=$(realpath "$kernels_dir"/"$version"_kvmconfig)

mkdir -p "$kernels_dir"

pushd "$linux_source_dir"

git checkout "$version"

"$patch_kernel_sources" .

echo
echo "Please check $(pwd) and fix all possible conflicts, then continue"
echo
read

make O="$kernel_dir" alldefconfig
make O="$kernel_dir" kvmconfig

function enable_config() {
    echo ./scripts/config --file="$kernel_dir" .config -e $1
}

enable_config MODULES
enable_config EXT4_FS

make O="$kernel_dir" -j 4

popd
