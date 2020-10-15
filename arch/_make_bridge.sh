#!/bin/bash

set -euo pipefail

if [ -d /sys/class/net/br-vms ]; then
    # already configured
    exit 0
fi

brctl addbr br-vms
ip addr add 10.0.2.1/24 dev br-vms
ip link set dev br-vms up

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -I POSTROUTING -s 10.0.2.0/24 ! -o br-vms -j MASQUERADE
iptables -t filter -I FORWARD -o br-vms -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -I FORWARD -s 10.0.2.0/24 -j ACCEPT
