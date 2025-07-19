#!/bin/bash
# Script to initialize Kubernetes master node

master_ip=$1
pod_network_cidr=$2

sudo kubeadm init --apiserver-advertise-address=$master_ip --pod-network-cidr=$pod_network_cidr
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
