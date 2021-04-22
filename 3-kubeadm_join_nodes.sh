#!/bin/bash

if [ `uname -a | grep -iq microsoft` ]; then
        MP=multipass
else
        MP=multipass.exe
fi

if [ "$#" -ne 1 ]; then
        _self="${0##*/}"
        echo "Usage: $_self <number of nodes>"
        exit
fi

NUM_NODES=$1
NODES=$(eval echo worker{1..$NUM_NODES})

for NODE in ${NODES}
do
	# setup kubectl config on each node
	$MP exec ${NODE} -- bash -c "sudo mkdir -p /home/ubuntu/.kube/"
	$MP exec ${NODE} -- bash -c "sudo chown ubuntu:ubuntu /home/ubuntu/.kube/"
	$MP transfer kubeconfig.yaml ${NODE}:/home/ubuntu/.kube/config
	# get the kube join command using kubeadm
	$MP exec ${NODE} -- bash -c "kubeadm token create --print-join-command >> kubeadm_join_cmd.sh"
	$MP exec ${NODE} -- bash -c "sudo chmod +x kubeadm_join_cmd.sh"
	# execute the join command
	$MP exec ${NODE} -- bash -c "sudo sh ./kubeadm_join_cmd.sh"
done
echo "############################################################################"
echo "Kubernetes environment created!!!"
