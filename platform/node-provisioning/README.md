# Provisioning a new node to the MID.PSI

## Worker Node

### Installing and configuring packages
````
## Installing packages required
apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt-cache madison kubeadm
apt install kubeadm=1.31.6-1.1
apt-mark hold kubeadm

apt install kubelet=1.35.0-ubuntu24.04u1
apt-mark hold kubelet

apt install conntrack

## Install the rbd packages and update modprobe
apt install librbd1
apt install python3-rbd
modprobe rbd

## Update the containerd configuration file
containerd config default | sudo tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

## Setup ipv4 forwarding required by kubelet
sysctl net.ipv4.ip_forward=1

## Update the kubeadm startup flags
vi /var/lib/kubelet/kubeadm-flags.env
Remove the second argument added by kubeadm, should only have the --container-runtime-endpoint argument

kubeadm reset
````

### Add the following to /etc/crictl.yaml and save the file:
````
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: true
````
###  Only for the PST GPU Server
````
## Setup containerd to use the nvidia container runtime
sudo nvidia-ctk runtime configure --runtime=containerd

## Update the nvidia persistence service to setup the GPUs in persistence mode
vi /usr/lib/systemd/system/nvidia-persistenced.service
Ensure that the following flag is set in the ExecStart: --persistence-mode
Restart the following service: sudo systemctl restart nvidia-persistenced

````
## Master Node

On Dev11 Run the following command:
`kubeadm token create --print-join-command`

Copy that command paste it back onto the worker node

On Dev11, using kubectl update the calico daemonset using the following command: `kubectl edit daemonset calico-node -n kube-system`

Find the following key: IP_AUTODETECTION_METHOD and in the values add the interface associated to the EXDS network on your worker node

Save and close the file

Optional: If you don't want any new pods to be assigned to your node, you can immediately cordon by running the following command on Dev11: `kubectl cordon <node-name>`

Optional: If you don't want your new node to be used for metallb broadcasting, you can run the following command on Dev11: `kubectl label node <node-name> node.kubernetes.io/exclude-from-external-load-balancers=true` 

### Only if a PST GPU server exists in the cluster
```
## Create the NVIDIA runtime class
kubectl apply -f nvidia-runtime-class.yaml

## Add the nvidia device plugin helm repo
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update

## Install the nvidia device plugin
helm upgrade -i nvdp nvdp/nvidia-device-plugin --namespace nvidia-device-plugin --create-namespace --version 0.17.1 -f nvdp-values.yaml
````
