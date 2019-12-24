#!/bin/bash

ip addr add 10.0.2.1/24 dev tap-arch
ip link set dev tap-arch up

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -I POSTROUTING -s 10.0.2.0/24 ! -o tap-arch -j MASQUERADE
iptables -t filter -I FORWARD -o tap-arch -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -I FORWARD -s 10.0.2.0/24 -j ACCEPT
