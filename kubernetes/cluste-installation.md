# Kubernetes Cluster Setup (1 Master + 2 Workers)

## Prerequisites
- 3 Ubuntu machines (**1 master, 2 workers**)
- SSH access from **master → workers** (with passwordless login or SSH keys)
- All nodes must have **unique hostnames** and be able to reach each other

---

## Make Passwordless authentication on both the worker nodes
bash```
ssh-keygen -t rsa -b 4096
ssh-copy-id ubuntu@<worker-node-1-ip>
ssh-copy-id ubuntu@<worker-node-2-ip>
```

## Verify Login with `ubuntu user`
```bash
ssh ubuntu@192.168.1.11 hostname
ssh ubuntu@192.168.1.12 hostname
```

## Check if ubuntu is in the sudo group
On each node (master + workers):
```bash
groups ubuntu
```
Expected Output: `ubuntu : ubuntu adm cdrom sudo dip lxd`

## Allow passwordless sudo
```bash
sudo vim /etc/sudoers

ubuntu ALL=(ALL) NOPASSWD:ALL
```

## Test 
```bash
ssh ubuntu@<worker-node-ip> "sudo whoami"
```
Expected Output: `root`

## Create Script `k8s-cluster.sh`

```bash
#!/bin/bash
set -e

# ========== CONFIG ==========
MASTER_IP="<master-node-ip>"
WORKERS=("<worker-node-1-ip>" "<worker-node-2-ip>")
USER="ubuntu"   # Change this to your SSH username
POD_CIDR="192.168.0.0/16"
# =============================

setup_node() {
  NODE=$1
  echo "[INFO] Setting up node $NODE"
  ssh -o StrictHostKeyChecking=no $USER@$NODE "bash -s" <<'EOF'
    set -e
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Disable swap
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab

    # Kernel modules
    sudo modprobe overlay
    sudo modprobe br_netfilter

    # Sysctl params
    cat <<SYSCTL | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
SYSCTL
    sudo sysctl --system

    # Install containerd
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    sudo apt-get install -y containerd
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    # Install Kubernetes
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update -y
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    echo "[INFO] Node setup complete on $(hostname)"
EOF
}

# ========== MAIN ==========
echo "[STEP 1] Setting up all nodes..."
setup_node $MASTER_IP
for w in "${WORKERS[@]}"; do
  setup_node $w
done

echo "[STEP 2] Initializing Kubernetes master..."
ssh $USER@$MASTER_IP "sudo kubeadm reset -f"
JOIN_CMD=$(ssh $USER@$MASTER_IP "sudo kubeadm init --pod-network-cidr=$POD_CIDR | tee /tmp/kubeinit.log | grep 'kubeadm join' -A 1")

echo "[STEP 3] Configuring kubectl on master..."
ssh $USER@$MASTER_IP "mkdir -p \$HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config && sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"

echo "[STEP 4] Installing Calico CNI..."
ssh $USER@$MASTER_IP "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"

echo "[STEP 5] Joining workers..."
for w in "${WORKERS[@]}"; do
  ssh $USER@$w "sudo kubeadm reset -f"
  ssh $USER@$w "sudo $JOIN_CMD"
done

echo "[STEP 6] Cluster setup complete. Verify with:"
echo "ssh $USER@$MASTER_IP kubectl get nodes"
````

---

## Usage

1. Copy the script to your **master node**:

```bash
nano k8s-cluster.sh
chmod +x k8s-cluster.sh
```

2. Update the variables inside (**MASTER\_IP, WORKERS, USER**).

3. Run it:

```bash
./k8s-cluster.sh
```

4. Verify:

```bash
kubectl get nodes
```

---

##Expected Output

```bash

NAME       STATUS   ROLES           AGE   VERSION
master     Ready    control-plane   2m    v1.31.3
worker1    Ready    <none>          1m    v1.31.3
worker2    Ready    <none>          1m    v1.31.3
```
