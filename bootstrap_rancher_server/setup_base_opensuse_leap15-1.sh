echo "############################################################################"
echo "Install basic tools for Rancher server. --- OS: openSUSE LEAP 15.1 ---"
echo "############################################################################"

sudo zypper --non-interactive ref
sudo zypper --non-interactive update


sudo zypper --non-interactive install curl
sudo zypper --non-interactive install nano

# Docker-ce
sudo zypper --non-interactive install docker
sudo systemctl start docker
sudo systemctl enable docker


sudo zypper --non-interactive install neofetch
sudo bash -c $'echo "neofetch" >> /etc/profile.d/mymotd.sh && chmod +x /etc/profile.d/mymotd.sh'