#!/bin/bash

# patch the VM's filesystem with wanted settings:
# 1. networking config that matches those set on the host (see configure_tap_arch.sh)
# 2. ssh server
# 3. sshfs

set -e

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 /path/to/disk"
    exit 1
fi

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

TMPMOUNT=$DIR/.tmpmount
mkdir -p $TMPMOUNT

mount "$1" $TMPMOUNT

cat <<EOF > $TMPMOUNT/root/setup.sh
#!/bin/bash

# setup networking
cat <<2EOF > /etc/systemd/network/ens3.network
[Match]
Name=ens3

[Network]
Address=10.0.2.2/24
Gateway=10.0.2.1
DNS=8.8.8.8

2EOF

cat <<2EOF > /etc/resolv.conf
nameserver 8.8.8.8

2EOF

systemctl start systemd-networkd.service
systemctl enable systemd-networkd.service

# ssh
pacman --noconfirm -S openssh

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

systemctl start sshd
systemctl enable sshd

EOF

umount $TMPMOUNT
