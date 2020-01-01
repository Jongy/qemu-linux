#!/bin/bash

set -e

if [[ "$#" -ne 1 ]]; then
    echo "$0 tap_name"
    exit 1
fi

tap_name="$1"

ip addr flush dev "$tap_name"

iptables -t nat -D POSTROUTING -s 10.0.2.0/24 ! -o "$tap_name" -j MASQUERADE
iptables -t filter -D FORWARD -o "$tap_name" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -D FORWARD -s 10.0.2.0/24 -j ACCEPT
