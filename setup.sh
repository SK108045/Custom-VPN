#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install necessary prerequisites
sudo apt install -y ca-certificates wget net-tools gnupg

# Add OpenVPN Access Server repository
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | sudo apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main" | sudo tee /etc/apt/sources.list.d/openvpn-as-repo.list

# Install OpenVPN Access Server
sudo apt update && sudo apt install -y openvpn-as

# Initialize OpenVPN Access Server
sudo /usr/local/openvpn_as/bin/ovpn-init --force

# Configure OpenVPN with public IP
sudo /usr/local/openvpn_as/scripts/sacli --key "host.name" --value "$PUBLIC_IP" ConfigPut
sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.daemon.0.server_ip_address" --value "$PUBLIC_IP" ConfigPut
sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.daemon.0.listen_ip_address" --value "$PUBLIC_IP" ConfigPut

# Restart OpenVPN Access Server
sudo /usr/local/openvpn_as/scripts/sacli start
sudo systemctl restart openvpnas

# Output admin login info
echo "Access the Admin UI at: https://$PUBLIC_IP:943/admin"
echo "Login with the 'openvpn' user and the password you set during initialization."
