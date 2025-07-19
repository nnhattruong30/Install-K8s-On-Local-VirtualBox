#!/bin/bash
# Script to initialize first Kubernetes master node

master_ip=$1
pod_network_cidr=$2
calico_version=$3

kubeadm init \
    --control-plane-endpoint $master_ip \
    --upload-certs \
    --pod-network-cidr=$pod_network_cidr

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v${calico_version}/manifests/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
