#!/bin/bash

# Simple Linux Router Setup Script for Home Lab
# Tested on Debian/Ubuntu-based systems

WAN_IF="eth0"
LAN_IF="eth1"
LAN_IP="192.168.10.1"
LAN_CIDR="192.168.10.0/24"
DHCP_RANGE_START="192.168.10.100"
DHCP_RANGE_END="192.168.10.200"

echo "[+] Installing required packages..."
apt update && apt install -y iptables dnsmasq iptables-persistent

echo "[+] Enabling IP forwarding..."
sed -i 's/#*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

echo "[+] Configuring LAN interface with static IP..."
ip addr flush dev "$LAN_IF"
ip addr add "$LAN_IP/24" dev "$LAN_IF"
ip link set "$LAN_IF" up

echo "[+] Setting up NAT and forwarding rules..."
iptables -t nat -A POSTROUTING -o "$WAN_IF" -j MASQUERADE
iptables -A FORWARD -i "$LAN_IF" -o "$WAN_IF" -j ACCEPT
iptables -A FORWARD -i "$WAN_IF" -o "$LAN_IF" -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "[+] Saving iptables rules..."
iptables-save > /etc/iptables/rules.v4

echo "[+] Configuring dnsmasq for DHCP and DNS..."
cat <<EOF > /etc/dnsmasq.conf
interface=$LAN_IF
dhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,12h
domain=homelab.local
EOF

echo "[+] Restarting dnsmasq..."
systemctl restart dnsmasq
systemctl enable dnsmasq

echo "[+] Basic router setup complete!"
echo "Devices on $LAN_CIDR will get DHCP and have internet access via $WAN_IF."
