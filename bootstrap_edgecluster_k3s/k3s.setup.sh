#!/bin/bash

set -euxo pipefail

echo "######################################################################################"
echo "Set up the K3s cluster environment"
echo "######################################################################################"

SERVER_KIND="$1"; shift
MODE="$1"; shift
K3S_CHANNEL="$1"; shift
K3S_VERSION="$1"; shift
K3S_TOKEN="$1"; shift
FLANNEL_BACKEND="$1"; shift
DOMAIN="$1"; shift
MAIN_MASTER_HOSTNAME="$1"; shift
IP_ADDR="$1"; shift

echo $SERVER_KIND $MODE

# Logic to check if machine is first- or n- Master-Node or Worker-Node via passed args
if [ $SERVER_KIND == "master" ]; then


if [ $MODE == "init" ]; then
    k3s_mode="--cluster-init"
elif [ $MODE == "join" ]; then
    k3s_mode="--server https://$MAIN_MASTER_HOSTNAME.$DOMAIN:6443"
    echo k3s_mode
else 
    echo "Error: Wrong arguments passed for ./bootstrap_edgecluster_k3s/k3s.setup.sh !"
    exit 1
fi

curl -sfL https://raw.githubusercontent.com/k3s-io/k3s/$K3S_VERSION/install.sh \
    | \
        INSTALL_K3S_CHANNEL="$K3S_CHANNEL" \
        INSTALL_K3S_VERSION="$K3S_VERSION" \
        K3S_TOKEN="$K3S_TOKEN" \
        sh -s -- \
            server \
            --node-taint CriticalAddonsOnly=true:NoExecute \
            --node-ip "$IP_ADDR" \
            --cluster-cidr '10.12.0.0/16' \
            --service-cidr '10.13.0.0/16' \
            --cluster-dns '10.13.0.10' \
            --cluster-domain 'cluster.local' \
            --flannel-iface 'eth1' \
            --flannel-backend $FLANNEL_BACKEND \
            --disable servicelb \
            $k3s_mode

# # BOOTSTRAP: Waiting for the node to be ready...
# $SHELL -c 'node_name=$(hostname); echo "waiting for node $node_name to be ready..."; while [ -z "$(kubectl get nodes $node_name | grep -E "$node_name\s+Ready\s+")" ]; do sleep 3; done; echo "node ready!"'
# # BOOTSTRAP: Waiting for kube-dns pod to be running...
# $SHELL -c 'while [ -z "$(kubectl get pods --selector k8s-app=kube-dns --namespace kube-system | grep -E "\s+Running\s+")" ]; do sleep 3; done'

# Symlink
ln -s /etc/rancher/k3s/k3s.yaml ~/.kube/config

# Makes operations available as user "vagrant" (default non-root)
sudo chown 1000:1000 /etc/rancher/k3s/k3s.yaml
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown 1000:1000 /home/vagrant/.kube/config

elif [ $SERVER_KIND == "worker" ]; then
curl -sfL https://raw.githubusercontent.com/k3s-io/k3s/$K3S_VERSION/install.sh \
| \
    INSTALL_K3S_CHANNEL="K3S_CHANNEL" \
    INSTALL_K3S_VERSION="$K3S_VERSION" \
    K3S_TOKEN="$K3S_TOKEN" \
    K3S_URL="https://$MAIN_MASTER_HOSTNAME.$(hostname --domain):6443" \
    sh -s -- \
        agent \
        --node-ip "$IP_ADDR" \
        --flannel-iface 'eth1'
        
else
    echo "Error: Wrong arguments passed for ./bootstrap_edgecluster_k3s/k3s.setup.sh !"
    exit 1
fi