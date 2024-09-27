# Custom VPN Setup with OpenVPN Access Server on AWS

![UserLogin](https://sk10codebase.online/images/Preview.png)

This github repo provides step-by-step instructions on how to set up a custom VPN using OpenVPN Access Server on an AWS EC2 instance. 

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
   - This command initializes OpenVPN Access Server, setting up its initial configuration.
      ```bash
      sudo /usr/local/openvpn_as/bin/ovpn-init --force
      ```
2. During the initialization:
   - Accept the EULA
   - Choose the default options for most prompts
   - When asked about the interface, choose the option for all interfaces (usually option 1)
   - Set a strong password for the 'openvpn' user

3 .Configuring OpenVPN Access Server with Public IP

- Set the public IP and configure OpenVPN:
   ```bash
   PUBLIC_IP=your-instance-public-ip
   sudo /usr/local/openvpn_as/scripts/sacli --key "host.name" --value "$PUBLIC_IP" ConfigPut
   sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.daemon.0.server_ip_address" --value "$PUBLIC_IP" ConfigPut
   sudo /usr/local/openvpn_as/scripts/sacli --key "vpn.daemon.0.listen_ip_address" --value "$PUBLIC_IP" ConfigPut
   ```
- These commands set the public IP for the OpenVPN server, ensuring it uses the correct IP for external connections.
- Apply changes and restart the service:
   ```bash
   sudo /usr/local/openvpn_as/scripts/sacli start
   sudo systemctl restart openvpnas
   ```

## Accessing the Admin UI

1. Open a web browser and navigate to `https://your-instance-public-ip:943/admin`
2. Log in with the username 'openvpn' and the password you set during initialization

![AdminLogin](https://sk10codebase.online/images/AdminLogin.png)

## Creating Users

1. In the Admin UI, go to "User Management" > "User Permissions"
2. Click "Create New User"
3. Enter a username and password
4. Set appropriate permissions (usually "Allow Auto-login" is sufficient)
5. Click "Save Settings"

![UserCreation](https://sk10codebase.online/images/UserCreation.png)

## Connecting to Your VPN

1. Access the Client UI:
   - Open a web browser and navigate to `https://[Your Instance Public IP]:943/`
   - You'll see a login page similar to this:
   
![UserLogin](https://sk10codebase.online/images/UserLogin.png)

2. Log in with your user credentials:
   - Enter the username and password you created in the Admin UI
   - After logging in, you'll see the client portal:
   
3. Download the OpenVPN Connect app:
   - In the client portal, you'll see options to download the OpenVPN Connect app for various platforms
   - Click on the Windows option to download the installer
   
![InsideUser](https://sk10codebase.online/images/InsideUser.png)

4. Install OpenVPN Connect:
   - Run the downloaded installer and follow the prompts to install OpenVPN Connect on your machine, In this case i used windows.
   
![Installation](https://sk10codebase.online/images/Installation.png)

5. Download your connection profile:
   - In the client portal, you should see an option to download your connection profile
   - This is typically an `.ovpn` file
   - Download this file to your computer

6. Import the profile and connect:
   - Open the OpenVPN Connect app
   - Import the `.ovpn` file you downloaded
   - Click the connect button to establish a VPN connection
   
   ![Installation](https://sk10codebase.online/images/OpenVpn.png)

7. Verify your connection:
   - Once connected, the OpenVPN Connect app should show a "Connected" status
   - You can now browse the internet through your VPN connection

Note: Always ensure you're connecting to your VPN from a secure network. Public Wi-Fi networks can be risky for entering login credentials.


## Troubleshooting

### If you encounter issues:

1. Check the OpenVPN Access Server logs:
   
   ```bash
   sudo tail -n 100 /var/log/openvpnas.log
   ```
2. Ensure the service is running:

   ```bash
   sudo systemctl status openvpnas
   ```

3. Verify that the server is listening on the correct ports:

   ```bash
   sudo netstat -tuln | grep -E ':(943|443|1194)'
   ```
4. Check your EC2 instance's security group settings

## Security Considerations

- Keep your EC2 instance and OpenVPN Access Server updated
- Use strong passwords and consider implementing multi-factor authentication
- Regularly review and update user access
- Consider setting up a proper SSL certificate for the Admin UI

## Maintenance
- Regularly update your system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
- Monitor server resources and adjust instance type if necessary
- Regularly backup your OpenVPN configuration:
   ```bash
   sudo cp -r /usr/local/openvpn_as/etc /path/to/backup/location
   ```
