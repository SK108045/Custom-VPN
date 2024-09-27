# Custom VPN Setup with OpenVPN Access Server on AWS

This guide provides step-by-step instructions on how to set up a custom VPN using OpenVPN Access Server on an AWS EC2 instance. 

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setting up the AWS EC2 Instance](#setting-up-the-aws-ec2-instance)
3. [Installing OpenVPN Access Server](#installing-openvpn-access-server)
4. [Configuring OpenVPN Access Server](#configuring-openvpn-access-server)
5. [Accessing the Admin UI](#accessing-the-admin-ui)
6. [Creating Users](#creating-users)
7. [Connecting to Your VPN](#connecting-to-your-vpn)
8. [Troubleshooting](#troubleshooting)
9. [Security Considerations](#security-considerations)
10. [Maintenance](#maintenance)

## Prerequisites

- An AWS account
- Basic knowledge of AWS EC2
- A domain name (optional, but recommended for production use)

## Setting up the AWS EC2 Instance

1. Log in to your AWS Console
2. Launch a new EC2 instance:
   - Choose Ubuntu Server 20.04 LTS or later
   - Select an instance type (t2.micro is sufficient for testing)
   - Configure instance details as needed
   - Configure security group:
     - Allow SSH (port 22) from your IP
     - Allow TCP 443 and 943, and UDP 1194 from anywhere (0.0.0.0/0)
   - Review and launch
   - Create or select an existing key pair 

## Installing OpenVPN Access Server
1. SSH into your EC2 instance:
   ```bash
    ssh -i your-key.pem ubuntu@your-instance-public-ip
   ```
   Replace `your-key.pem` with the path to your private key file and `your-instance-public-ip` with your EC2 instance's public IP address.
2. Update the system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. Install OpenVPN Access Server:
   - Install necessary prerequisites for OpenVPN Access Server.
 
     ```bash
     sudo apt install ca-certificates wget net-tools gnupg
     ```
   
   - Then download and add the OpenVPN Access Server repository's GPG key.
     ```bash
     wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | sudo apt-key add -
     ```
   - Add the OpenVPN Access Server repository to the system's package sources.
     ```bash
     echo "deb http://as-repository.openvpn.net/as/debian focal main" | sudo tee /etc/apt/sources.list.d/openvpn-as-repo.list
     ```
   - Update the package lists again and install OpenVPN Access Server
     ```bash
     sudo apt update && sudo apt install openvpn-as
     ```
## Configuring OpenVPN Access Server

1. Initialize OpenVPN Access Server:

Copy

Apply

sudo /usr/local/openvpn_as/bin/ovpn-init --force

This command initializes OpenVPN Access Server, setting up its initial configuration.

2. During the initialization:
- Accept the EULA
- Choose the default options for most prompts
- When asked about the interface, choose the option for all interfaces (usually option 1)
- Set a strong password for the 'openvpn' user

3. Configure OpenVPN to use your public IP:

Copy

Apply

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

Retrieves the public IP address of your EC2 instance.


Copy

Apply

sudo /usr/local/openvpn_as/scripts/sacli --key "host.name" --value "$PUBLIC_IP" ConfigPut

Sets the hostname of the OpenVPN server to your public IP.


Copy

Apply

sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.daemon.0.server_ip_address" --value "$PUBLIC_IP" ConfigPut

Configures the OpenVPN daemon to use your public IP as the server address.


Copy

Apply

sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.daemon.0.listen_ip_address" --value "$PUBLIC_IP" ConfigPut

Sets the listen address for the OpenVPN daemon to your public IP.

4. Apply changes and restart the service:

Copy

Apply

sudo /usr/local/openvpn_as/scripts/sacli start

Applies the configuration changes.


Copy

Apply

sudo systemctl restart openvpnas

Restarts the OpenVPN Access Server service to ensure all changes take effect.
