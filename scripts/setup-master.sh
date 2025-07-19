#!/bin/bash
# Script to setup additional master node

mkdir -p /home/vagrant/.kube
kubectl taint nodes $(hostname) node-role.kubernetes.io/control-plane- || true
