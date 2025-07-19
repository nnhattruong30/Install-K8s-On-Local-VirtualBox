#!/bin/bash

set -e

# Load environment variables
load_env() {
    source .env
    export VAGRANT_CWD="$PWD/vagrant"
}

# Start all VMs
start_vms() {
    echo "Starting Kubernetes cluster with $TOTAL_VMS nodes..."
    vagrant up --parallel
}

# Wait for VMs to be ready
wait_for_vms() {
    for i in $(seq 1 $TOTAL_VMS); do
        echo "Waiting for Node-$i..."
        while ! vagrant ssh Node-$i -c "echo ready" &>/dev/null; do sleep 5; done
    done
}

# Initialize master node
init_master() {
    echo "Initializing master node..."
    master_ip=$(vagrant ssh Node-1 -c "ip route get 1 | awk '{print \$7; exit}'" 2>/dev/null | tr -d '\r')
    echo "Using master IP: $master_ip"
    echo "Using pod network CIDR: $POD_NETWORK_CIDR"

    vagrant upload scripts/init-master.sh /tmp/init-master.sh Node-1
    vagrant ssh Node-1 -c "chmod +x /tmp/init-master.sh && /tmp/init-master.sh $master_ip $POD_NETWORK_CIDR"
}

# Install Calico network
install_calico() {
    echo "Installing Calico network v$CALICO_VERSION..."
    vagrant upload scripts/install-calico.sh /tmp/install-calico.sh Node-1
    vagrant ssh Node-1 -c "chmod +x /tmp/install-calico.sh && /tmp/install-calico.sh $CALICO_VERSION"
}

# Join nodes to cluster
join_nodes() {
    if [ $TOTAL_VMS -gt 1 ]; then
        join_cmd=$(vagrant ssh Node-1 -c "sudo kubeadm token create --print-join-command" 2>/dev/null | tail -1)
        
        for i in $(seq 2 $TOTAL_VMS); do
            echo "Joining Node-$i to cluster..."
            vagrant upload scripts/join-node.sh /tmp/join-node.sh Node-$i
            vagrant ssh Node-$i -c "chmod +x /tmp/join-node.sh && /tmp/join-node.sh '$join_cmd'"
            
            # If it's Node-2, make it a master too and allow scheduling
            if [ $i -eq 2 ]; then
                vagrant ssh Node-1 -c "cat /home/vagrant/.kube/config" | vagrant ssh Node-$i -c "cat > /home/vagrant/.kube/config"
                vagrant upload scripts/setup-master.sh /tmp/setup-master.sh Node-$i
                vagrant ssh Node-$i -c "chmod +x /tmp/setup-master.sh && /tmp/setup-master.sh"
            fi
        done
    fi
}

# Main function
main() {
    load_env
    start_vms
    wait_for_vms
    init_master
    install_calico
    join_nodes

    echo "Cluster ready! Access with: VAGRANT_CWD=vagrant vagrant ssh Node-1"
}

main
