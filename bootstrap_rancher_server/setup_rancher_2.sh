#!/bin/bash

echo "############################################################################"
echo "Set up Rancher 2 server via Docker"
echo "############################################################################"

HOME_V="/home/vagrant"

sudo docker pull rancher/rancher:latest

# TLS Port: 8080 is VM, 443 is Container. 8080 will be forwarded to Host-Sytem on 9090, 9091, ...
# Forward-Chain: Container:443->VM:8080->Host:9090
# E.g. on Host to access Rancher Dashboard: https://127.0.0.1:9090
sudo docker run -d --restart=unless-stopped \
  -p 80:80 -p 8080:443 \
  --privileged \
  rancher/rancher:latest

echo "Waiting for Rancher curl to return status code 200..."
while true; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" https://localhost:8080)
    if [ $status_code -eq 400 ]; then
        printf "\nstatus code is 400 so the server started...\n"
        break
    else
        printf "\nstatus code is $status_code\n"
    fi
    echo "sleep 5 secs.."
    sleep 5
done

# Get bootstrap Rancher password which will be replaced in first - save it in tmp dir
process=$(docker ps -a --filter ancestor=rancher/rancher:latest --format "{{.ID}}")
bootstrap_password_rancher=$(sudo docker logs  $process   2>&1 | grep "Bootstrap Password:")
echo bootstrap_password_rancher > $HOME_V/tmp/rancherserver_initial_password.txt
echo "Initial password for user Rancher Server :::::\n\n\n$(cat $HOME_V/tmp/rancherserver_initial_password.txt)\n\n\n"

