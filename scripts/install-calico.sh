#!/bin/bash
# Script to install Calico network plugin

calico_version=$1

curl -s -O https://raw.githubusercontent.com/projectcalico/calico/v${calico_version}/manifests/tigera-operator.yaml
curl -s -O https://raw.githubusercontent.com/projectcalico/calico/v${calico_version}/manifests/custom-resources.yaml
kubectl apply -f tigera-operator.yaml
kubectl apply -f custom-resources.yaml
