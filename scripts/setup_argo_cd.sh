#!/bin/bash

# set -euxo pipefail

echo "###########################################################################"
echo "Setup ArgoCD continuous delivery service"
echo "###########################################################################"

HOME_V="/home/vagrant"

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
# Tweak: Set --server.insecure: "true" via cm to let traefik do the certificate handling
# Reference: https://stackoverflow.com/a/71692892
kubectl apply -k $HOME_V/manifests/argo_cd_continuous_delivery/installation # dir

echo "-> Exposing the service via ingress at domain: https://argocd.$(hostname --domain)"

sed -i "s/{{DOMAIN}}/$(hostname --domain)/g" $HOME_V/manifests/argo_cd_continuous_delivery/ingress.yaml
kubectl apply -n argocd -f $HOME_V/manifests/argo_cd_continuous_delivery/ingress.yaml
sed -i "s/$(hostname --domain)/{{DOMAIN}}/g" $HOME_V/manifests/argo_cd_continuous_delivery/ingress.yaml

TIMEOUT="180s"
echo "Wait for all deployments in namespace "argocd" to be ready. Set a timeout of $TIMEOUT ..."
kubectl wait deployment -n argocd \
    argocd-applicationset-controller \
    argocd-dex-server \
    argocd-notifications-controller \
    argocd-redis argocd-repo-server \
    argocd-server \
    --for condition=Available=True --timeout=$TIMEOUT

# Use this to log in with username: "admin"
# Note: This is an initial generic password auto-generated in the ArgoCD deployment. In production, it should be changed asap!
# Reference on how to reset the password: https://github.com/argoproj/argo-cd/blob/master/docs/faq.md#i-forgot-the-admin-password-how-do-i-reset-it
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > $HOME_V/tmp/argocd_initial_password.txt

echo "Initial password for user "admin":::::\n\n\n$(cat $HOME_V/tmp/argocd_initial_password.txt)\n\n\nNOTE: Change this immediately in production!" #################'