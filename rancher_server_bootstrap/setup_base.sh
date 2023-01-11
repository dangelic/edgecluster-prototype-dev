#!/bin/bash

echo "############################################################################"
echo "Install basic tools for Rancher server"
echo "############################################################################"


# To avoid interaction with the terminal
export DEBIAN_FRONTEND=noninteractive

echo "--> Update package manager..."
sudo apt-get update
sudo apt-get upgrade

# --- Common: Executed on every VM
echo "--> Installing useful tools..."
sudo apt-get install -y jq
sudo apt-get install -y curl
sudo apt-get install -y iptables
sudo apt-get install -y tcpdump
sudo apt-get install -y traceroute
sudo apt-get install -y gpg
sudo apt-get install -y python3
sudo apt-get install -y python3-yaml
# One-script-to-rule-it-all-Docker-installation
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# MOTD neofetch as welcome banner for the servers' CLI
sudo apt-get install -y neofetch
sudo bash -c $'echo "neofetch" >> /etc/profile.d/mymotd.sh && chmod +x /etc/profile.d/mymotd.sh'