#!/bin/bash

if [ "$#" -ne 1 ]; then 
	_self="${0##*/}"
	echo "Usage: $_self <number of nodes>"
	exit
fi

res1=$(date +%s)
./1-deploy-master-flannel.sh
./2-deploy-nodes.sh $1
./3-kubeadm_join_nodes.sh $1
res2=$(date +%s)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
# printf "Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
printf "Total runtime in minutes was: %02d:%02.f\n" $dm $ds
echo "############################################################################"
