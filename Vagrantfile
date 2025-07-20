# -*- mode: ruby -*-
# vi: set ft=ruby :
$total = 3

Vagrant.configure(2) do |config|
  vb_group = "/Local_K8s_Cluster"

  (1..$total).each do |i|
    config.vm.define "Node-#{i}" do |node|
      node.vm.box = 'local/ubuntu-server-24'                    
      node.vm.hostname = "k8s-node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.11#{i}"
      node.vm.synced_folder './volume/', '/home/vagrant/sync'

      node.vm.provider "virtualbox" do |vb|
        vb.name = "k8s-node-#{i}"
        vb.cpus = 2
        vb.memory = "4096"
        vb.customize ["modifyvm", :id, "--groups", vb_group]
      end
    end
  end

config.vm.provision "shell", path: "../bootstrap.sh"

end