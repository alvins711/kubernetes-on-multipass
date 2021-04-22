#!/bin/bash

if [ `uname -a | grep -iq microsoft` ]; then
	MP=multipass
else
	MP=multipass.exe
fi


$MP launch ubuntu --name master --cpus 2 --mem 2G --disk 10G
## setup docker
$MP exec master -- bash -c 'sudo apt-get update'
$MP exec master -- bash -c 'sudo apt-get install docker.io -y'
$MP exec master -- bash -c 'sudo usermod -aG docker ubuntu'
$MP transfer daemon.json master:daemon.json
$MP exec master -- bash -c 'sudo cp /home/ubuntu/daemon.json /etc/docker/daemon.json'
$MP exec master -- bash -c 'sudo systemctl start docker'
$MP exec master -- bash -c 'sudo systemctl enable docker'

## install kubernetes
$MP exec master -- bash -c 'curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add'
$MP exec master -- bash -c 'sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"'
$MP exec master -- bash -c 'sudo apt-get install kubeadm kubelet kubectl -y'

# Get master node's IP address
#CMD="sudo kubeadm init --pod-network-cidr=`$MP list |grep master | awk '{print $3}'`/16"
#echo "CMD is: ${CMD}"

# create cluster
$MP exec master -- bash -c 'sudo swapoff -a'
$MP exec master -- bash -c "sudo kubeadm init --pod-network-cidr=`$MP list |grep master | awk '{print $3}'`/16"

# setup kube config
$MP exec master -- bash -c 'mkdir -p $HOME/.kube'
$MP exec master -- bash -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
$MP exec master -- bash -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'

# copy kube config to local machine, used to setup workers
$MP transfer master:.kube/config kubeconfig.yaml

# deploy pod network to cluster
$MP exec master -- bash -c 'kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml'


echo "Master node created"
echo "Create the worker nodes next"

