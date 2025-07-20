#!/bin/bash
K8S_VERSION="1.33"

# Upgrade system
apt-get update && apt-get upgrade -y

# Turn off swap
swapoff -a
sed -i '/swap.img/s/^/#/' /etc/fstab

# Configure module kernel
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Configure network
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl
sysctl --system

# Install necessary packages
apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release containerd

# Configure & enable containerd service
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
# sed -i 's|sandbox_image = ".*"|sandbox_image = "registry.k8s.io/pause:3.10"|g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Add k8s repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update


# Install specific version
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Display versions of installed packages
echo "=== Kubernetes Package Versions ==="
dpkg -l kubelet kubeadm kubectl

# Display IPv4 addresses
echo "=== IPv4 Addresses ==="
ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | while read addr; do
    echo "IP: $addr"
done
