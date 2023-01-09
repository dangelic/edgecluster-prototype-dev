#!/bin/bash

echo "###########################################################################"
echo "Setup Portainer (deployment, rbac, sa, pvc, ing)"
echo "###########################################################################"

HOME_V="/home/vagrant"

kubectl apply -f $HOME_V/manifests/portainer/portainer.yaml

echo "-> Exposing the service via ingress at domain: https://portainer.$(hostname --domain)"

sed -i "s/{{DOMAIN}}/$(hostname --domain)/g" $HOME_V/manifests/portainer/ingress.yaml
kubectl apply -n portainer -f $HOME_V/manifests/portainer/ingress.yaml
sed -i "s/$(hostname --domain)/{{DOMAIN}}/g" $HOME_V/manifests/portainer/ingress.yaml

# Portainer deployment must be restarted to function properly
# This is accomplished by scaling the replicas down and up
echo "-> Restarting service..."
kubectl scale --replicas=0 deployment portainer -n portainer
sleep 10
kubectl scale --replicas=1 deployment portainer -n portainer
echo "done."