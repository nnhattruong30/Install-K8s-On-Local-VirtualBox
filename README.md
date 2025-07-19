# Install-K8s-On-Local-VirtualBox

This project provides automated scripts to deploy Kubernetes clusters on local VirtualBox VMs using Vagrant.

## Quick Start

### Prerequisites
- VirtualBox installed
- Vagrant installed
- Local Ubuntu box named `local/ubuntu-server-24` (see [vagrant setup](./vagrant/README.md))

### Launch Kubernetes Cluster

The script reads the number of nodes from the `.env` file's `TOTAL_VMS` variable:

```bash
# Use TOTAL_VMS from .env file (currently set to 2)
./launch-k8s-cluster.sh

# Override with specific number of nodes
./launch-k8s-cluster.sh 1  # Single node cluster
./launch-k8s-cluster.sh 3  # 3-node cluster (2 masters + 1 worker)
./launch-k8s-cluster.sh 5  # 5-node cluster (2 masters + 3 workers)
```

### Configuration

Edit the `.env` file to change default settings:
```bash
# Number of VMs to create
TOTAL_VMS=2
# Kubernetes version to install
K8S_VERSION=1.30
```

### Cluster Configuration
- **1 node**: 1 master node (also acts as worker)
- **2+ nodes**: 2 master nodes (both act as workers) + additional worker nodes
- **Network**: Calico CNI plugin
- **Pod CIDR**: 10.244.0.0/16
- **Service CIDR**: 10.96.0.0/12

### Access the Cluster

```bash
cd vagrant
vagrant ssh Node-1
kubectl get nodes
kubectl get pods --all-namespaces
```

### Cleanup

```bash
./cleanup-k8s-cluster.sh
```

## Manual Setup
[Launch VM manually](./vagrant/README.md)