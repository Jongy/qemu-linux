#!/bin/bash
ip addr flush dev tap-qemu
ip addr add 10.1.0.1/24 dev tap-qemu
ip link set dev tap-qemu up
