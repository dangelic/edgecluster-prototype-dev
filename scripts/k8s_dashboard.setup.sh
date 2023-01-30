#!/bin/bash

echo "###########################################################################"
echo "Setup Kubernetes dashboard (deployment, rbac, sa, ing)"
echo "###########################################################################"

HOME_V="/home/vagrant"

kubectl apply -f $HOME_V/manifests/k8s_dashboard/dashboard.yaml
kubectl apply -n kubernetes-dashboard -f $HOME_V/manifests/k8s_dashboard/serviceaccount.yaml
kubectl apply -n kubernetes-dashboard -f $HOME_V/manifests/k8s_dashboard/rbac.yaml

echo "-> Exposing the service via ingress at domain: https://kubernetes-dashboard.$(hostname --domain)"

sed -i "s/{{DOMAIN}}/$(hostname --domain)/g" $HOME_V/manifests/k8s_dashboard/ingress.yaml
kubectl apply -n kubernetes-dashboard -f $HOME_V/manifests/k8s_dashboard/ingress.yaml
sed -i "s/$(hostname --domain)/{{DOMAIN}}/g" $HOME_V/manifests/k8s_dashboard/ingress.yaml

echo "-> Generating Kubernetes dashboard admin token and store it in $HOME_V/tmp ..."

kubectl -n kubernetes-dashboard get secret admin -o json \
  | jq -r .data.token \
  | base64 --decode \
  >$HOME_V/tmp/k8s_dashboard_admin_token.txt

echo "TOKEN:::::\n\n\n$(cat $HOME_V/tmp/k8s_dashboard_admin_token.txt)\n\n\n"