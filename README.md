# 🚀 Kubernetes on Local VirtualBox with Vagrant

## 📋 Overview

Deploy a multi-node Kubernetes cluster on your local machine using VirtualBox and Vagrant!

## 📋 Prerequisites

> Reference: https://developer.hashicorp.com/vagrant/docs/boxes/base

To convert an Ubuntu VM into a Vagrant box, ensure the following requirements are met:
- 👤 A user named `vagrant` exists
- 🔐 Add the `vagrant` user to the `sudo` and `vagrant` groups by editing `/etc/sudoers`:
    ```
    vagrant ALL=(ALL) NOPASSWD: ALL
    ```
- 🔑 Add the Vagrant public key for the `vagrant` user:  
  https://github.com/hashicorp/vagrant/tree/main/keys/vagrant.pub

## 🛠️ Instructions

### 📦 Convert a VM into a Vagrant box

1. **📋 List all local VirtualBox VMs**
    ```sh
    VBoxManage list vms
    ```

2. **📦 Package a local VirtualBox VM**
    ```sh
    vagrant package --base <vm_id_or_name> --output Ubuntu.box
    ```
    Replace `<vm_id_or_name>` with your VM's ID or name.

3. **➕ Add the box to Vagrant**
    ```sh
    vagrant box add Ubuntu.box --name local/ubuntu-server-24
    ```

4. **📋 List all local Vagrant boxes**
    ```sh
    vagrant box list
    ```

### 🚀 Launch VMs

1. **⚙️ Configure the number of VMs to start**
    - Edit the [Vagrantfile](./Vagrantfile) and set the `$total` variable to the desired number of VMs
    - Update the `K8S_VERSION` in [bootstrap.sh](./scripts/bootstrap.sh) as needed

2. **🚀 Start the virtual machines**
    ```sh
    vagrant up --parallel
    ```
    The `--parallel` flag enables parallel startup if supported by the provider.

### ⚡ Initialize the Kubernetes Cluster

1. **🎯 Initialize the first master node**
    ```sh
    kubeadm init \
        --control-plane-endpoint <private_ip>:6443 \
        --apiserver-advertise-address <private_ip> \
        --upload-certs \
        --pod-network-cidr=<cidr_range>

    # Configure kubectl for the `vagrant` user
    mkdir -p /home/vagrant/.kube
    cp -fv /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown vagrant:vagrant /home/vagrant/.kube/config
    ```

2. **🌐 Install the Calico network plugin**
    ```sh
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v<version>/manifests/calico.yaml
    ```
    Replace `<version>` with the desired Calico version.

3. **🔗 Join additional master nodes**
    ```sh
    kubeadm join <master_ip>:6443 \
        --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash_string> \
        --control-plane \
        --certificate-key <cert_key>
        --apiserver-advertise-address <private_ip> \
    ```

4. **👷 Join worker nodes**
    ```sh
    kubeadm join <master_ip>:6443 --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash_string>
    ```

## 🔧 Useful Vagrant Commands

- **🛑 Shut down**
    ```sh
    vagrant halt
    ```

- **💥 Destroy all VMs**
    ```sh
    vagrant destroy -f
    ```
    The `-f` or `--force` flag destroys VMs without confirmation.

- **📸 Take snapshots for all VMs**
    ```sh
    vagrant snapshot save install_prerequisite
    ```