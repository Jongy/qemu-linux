#!/bin/bash

ip addr flush dev tap-arch

iptables -t nat -D POSTROUTING -s 10.0.2.0/24 ! -o tap-arch -j MASQUERADE
iptables -t filter -D FORWARD -o tap-arch -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -D FORWARD -s 10.0.2.0/24 -j ACCEPT
