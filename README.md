Create and control lightweight Linux VMs with QEMU.

Place files you want to be available inside the VM under `fs/`.

Compile:

    ./make_kvm_kernel /path/to/linux kernels v4.6 x86_64_defconfig

Run:

    ./run.sh kernels/v4.6_x86_64_defconfig_kvmconfig
