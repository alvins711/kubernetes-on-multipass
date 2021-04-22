#!/bin/bash

if [ `uname -a | grep -iq microsoft` ]; then
        MP=multipass
else
        MP=multipass.exe
fi

NUM_NODES=$1

if [ "$#" -ne 1 ]; then
        _self="${0##*/}"
        echo "Usage: $_self <number of nodes>"
        exit
fi

# Create multipass instances
NODES=$(eval echo worker{1..${NUM_NODES}})
for NODE in ${NODES}; do $MP launch --name ${NODE} --cpus 2 --mem 2G --disk 10G; done

# For each multipass node install docker, kubernetes
for NODE in ${NODES}
do
	## install docker
	$MP exec ${NODE} -- bash -c 'sudo apt-get update'
	$MP exec ${NODE} -- bash -c 'sudo apt-get install docker.io -y'
	$MP exec ${NODE} -- bash -c 'sudo usermod -aG docker ubuntu'
	$MP transfer daemon.json ${NODE}:daemon.json
	$MP exec ${NODE} -- bash -c 'sudo cp /home/ubuntu/daemon.json /etc/docker/daemon.json'
	$MP exec ${NODE} -- bash -c 'sudo systemctl start docker'
	$MP exec ${NODE} -- bash -c 'sudo systemctl enable docker'

	## install kubernetes
	$MP exec ${NODE} -- bash -c 'curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add'
	$MP exec ${NODE} -- bash -c 'sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"'
	$MP exec ${NODE} -- bash -c 'sudo apt-get install kubeadm kubelet kubectl -y'
	$MP exec ${NODE} -- bash -c 'sudo swapoff -a'
done

echo "Nodes created, time to join the cluster"

