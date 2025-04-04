#!/bin/bash

# Secure Website Hosting Setup Script
# Works on Ubuntu/Debian-based systems

set -e

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing Apache2..."
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

echo "[*] Installing BIND9..."
sudo apt install bind9 bind9utils bind9-doc -y

echo "[*] Installing Certbot..."
sudo apt install certbot python3-certbot-apache -y

echo "[*] Installing UFW and setting rules..."
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw allow 80,443/tcp
sudo ufw allow 53
sudo ufw --force enable

echo "[*] Installing Fail2Ban..."
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "[*] Enabling Apache security modules..."
sudo a2enmod rewrite headers ssl
sudo systemctl restart apache2

echo "[*] Apache basic security settings..."
SECURITY_CONF="/etc/apache2/conf-available/security.conf"
sudo sed -i 's/^ServerTokens.*/ServerTokens Prod/' $SECURITY_CONF
sudo sed -i 's/^ServerSignature.*/ServerSignature Off/' $SECURITY_CONF
echo "TraceEnable Off" | sudo tee -a $SECURITY_CONF

echo "[*] Restarting Apache..."
sudo systemctl restart apache2

echo ""
echo "===== NEXT STEPS MANUAL ====="
echo "- Configure BIND9 zone files under /etc/bind/zones"
echo "- Forward ports 80, 443, and 53 in your router to this server's IP"
echo "- Use certbot to get SSL: sudo certbot --apache -d yourdomain.com -d www.yourdomain.com"
echo "- Optional: Configure Fail2Ban jails in /etc/fail2ban/jail.local"
echo "- Optional: Set a static IP in your netplan config"

echo "[*] Setup complete."
