#!/bin/bash

echo "############################################################################"
echo "Install basic tools"
echo "############################################################################"


NODE_KIND="$1"; shift

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

# MOTD neofetch as welcome banner for the servers' CLI
sudo apt-get install -y neofetch
sudo bash -c $'echo "neofetch" >> /etc/profile.d/mymotd.sh && chmod +x /etc/profile.d/mymotd.sh'

# Master-only
if [ "$NODE_KIND" == 'master' ]; then
    echo "--> Installing Helm..."
    # See: https://helm.sh/docs/intro/install
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

    echo "--> Installing WireGuard..."
    sudo apt-get install -y wireguard
fi