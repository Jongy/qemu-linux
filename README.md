Create and control lightweight Linux VMs with QEMU.

Place files you want to be available inside the VM under `fs/`.

Compile:

    ./make_kvm_kernel /path/to/linux kernels v4.6

Run:

    ./run.sh kernels/v4.6_kvmconfig/bzImage
