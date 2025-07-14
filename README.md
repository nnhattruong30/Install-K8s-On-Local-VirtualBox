# Ubuntu Server Vagrant Project

## Introduction
This project sets up an Ubuntu server using Vagrant. Vagrant is a tool for building and managing virtual machine environments in a single workflow.

## Prerequisites
> Refer from: https://developer.hashicorp.com/vagrant/docs/boxes/base
- The Ubuntu VM is convert to Vagrant box need following:
    - A user named `vagrant`
    - Add this user to `sudo` and `vagrant` group by edit `/etc/sudoer`
        `vagrant ALL=(ALL) NOPASSWD: ALL`
    - Add the vagrant pubkey for `vagrant` user: https://github.com/hashicorp/vagrant/tree/main/keys/vagrant.pub


## Setup Instructions
1. **List all local virtual boxes**
    ```sh
    VBoxManage list vms
    ```

1. **Pack local virtualbox**
    ```sh
    vagrant package --base acef4c0a-35be-4640-a214-be135417f011 --output Ubuntu.box
    ```

1. **Add to the list of Vagrant boxes**
    ```sh
    vagrant box add Ubuntu.box --name local/ubuntu-server-24
    ```

1. **List all local Vagrant boxes**
    ```sh
    vagrant box list
    ```
1. **Configure the number of VMs to start**
    Edit the `Vagrantfile` to specify the desired number of VMs by setting the `$total` variable accondingly. This controls how many nodes will be provisioned

1. **Start the virtual machine**
    ```sh
    vagrant up --parallel
    ```
    --parallel      Enable parallelism if provider supports it

1. **Shut down the virtual machine**
    ```sh
    vagrant halt
    ```

1. **Destroy the virtual machine**
    ```sh
    vagrant destroy -f
    ```
    -f, --force     Destroy without confirmation
# Install-K8s-On-Local-VirtualBox
