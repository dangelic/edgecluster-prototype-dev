#!/bin/sh

# Helper
# Add vagrant-ssh of current Vagrant environment to regular ssh config and delete old config
# Note: Execute with sudo in current Vagrant environment (dir)


sudo sed -i '/#=#=#=#=# Vagrant SSH config limiter s #=#=#=#=#/,/#=#=#=#=# Vagrant SSH config limiter e #=#=#=#=#/d' /etc/ssh/ssh_config
sudo echo "#=#=#=#=# Vagrant SSH config limiter s #=#=#=#=#" >> /etc/ssh/ssh_config
sudo -u#$SUDO_UID vagrant ssh-config >> /etc/ssh/ssh_config
sudo echo "#=#=#=#=# Vagrant SSH config limiter e #=#=#=#=#" >> /etc/ssh/ssh_config