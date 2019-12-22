#!/bin/bash
# allows running qemu with KVM enabled w/o root.
set -e

echo "Adding $USER to kvm group"
sudo usermod --append -G kvm $USER
