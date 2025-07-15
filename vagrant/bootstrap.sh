#!/bin/bash
ip -c a

apt-get update && apt-get upgrade -y
# Install required packages
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg

# Add Kubernetes apt repository
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

# Update package index
apt-get update

# Install kubelet, kubeadm, and kubectl
apt-get install -y kubelet kubeadm kubectl

# Hold the versions
apt-mark hold kubelet kubeadm kubectl

# Disable swap (required by Kubernetes)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Enable required kernel modules and sysctl params
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install containerd
apt-get install -y containerd

# Configure containerd and restart
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Print completion message
echo "Kubernetes prerequisites installed. Ready for kubeadm init/join."