#!/bin/bash

echo "WARNING: This will destroy all VMs and clean up the cluster."
read -p "Are you sure? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd vagrant
    vagrant destroy -f
    cd ..
    echo "Cleanup completed!"
else
    echo "Cleanup cancelled."
fi
