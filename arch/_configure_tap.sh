#!/bin/bash

set -e

if [[ "$#" -ne 1 ]]; then
    echo "$0 tap_name"
    exit 1
fi

tap_name="$1"

ip addr add 10.0.2.1/24 dev "$tap_name"
ip link set dev "$tap_name" up

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -I POSTROUTING -s 10.0.2.0/24 ! -o "$tap_name" -j MASQUERADE
iptables -t filter -I FORWARD -o "$tap_name" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -I FORWARD -s 10.0.2.0/24 -j ACCEPT
