# Setup Kubernetes using Multipass

Collection of bash scripts to create a local Kubernetes cluster using Multipass virtual machines.

**Requirements**:
 1. Multipass installation on Windows, MacOS or Linux. See https://multipass.run/ for install instructions.
 2. If running on Windows, you need to enable Windows Subsystem for Linux. See https://docs.microsoft.com/en-us/windows/wsl/install-win10


## Download scripts
 1.  git clone https://github.com/alvins711/kubernetes-on-multipass.git

## Deployment instructions

 1. From a terminal window execute:
			./deploy.sh \<number of nodes> 

If using Windows, open a Linux terminal (requires Windows Subsystem for Linux).

 The deploy.sh script will execute the following scripts in the following order:
	1-deploy-master-flannel.sh - Creates a multipass VM for the K8 master
	2-deploy-nodes.sh - Creates multipass VMs as workers for the cluster (number of workers are configurable)
	3-kubeadm_join_nodes.sh - Joins workers to cluster
	
## Notes:

 - Currently Multipass instances uses dynamic IP addresses, If a Multipass instance is stopped and restarted it will obtain a new IP address and NFS mounts may not be re-established.
 - The instances is created with 2 CPU, 2G memory and 10G of disk space. These can be changed in the scripts - 1-deploy-master-flannel.sh and 2-deploy-nodes.sh

 
