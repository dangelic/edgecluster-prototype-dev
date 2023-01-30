#!/bin/bash

echo "############################################################################"
echo "Set up Rancher 2 server via Docker"
echo "############################################################################"

RANCHER_VERSION=$1

HOME_V="/home/vagrant"

sudo docker pull rancher/rancher:$RANCHER_VERSION

# TLS Port: 8080 is VM, 443 is Container. 8080 will be forwarded to Host-Sytem on 9090, 9091, ...
# Forward-Chain: Container:443->VM:8080->Host:9090
# E.g. on Host to access Rancher Dashboard: https://127.0.0.1:9090
sudo docker run -d --restart=unless-stopped \
  -p 80:80 -p 8080:443 \
  --privileged \
  rancher/rancher:$RANCHER_VERSION

echo "Grep bootstrap Rancher password once it appears in Docker logs - save it in tmp dir afterwards"
process=$(docker ps -a --filter ancestor=rancher/rancher:$RANCHER_VERSION --format "{{.ID}}")
while true; do
  bootstrap_password_rancher=$(sudo docker logs  $process   2>&1 | grep "Bootstrap Password:")
  # Check if the output is empty
  if [ -z "$bootstrap_password_rancher" ]; then
    echo "Grep returned nothing, wait 5 seconds and continuing loop..."
    sleep 5
  else
    echo $bootstrap_password_rancher > $HOME_V/tmp/rancherserver_initial_password.txt
    echo "Initial password for Rancher Server :::::\n\n\n$(cat $HOME_V/tmp/rancherserver_initial_password.txt)\n\n\n"
    break
  fi
done





