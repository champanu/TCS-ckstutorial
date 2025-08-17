<img width="1822" height="1310" alt="image" src="https://github.com/user-attachments/assets/b9db2399-a496-4e4a-b19f-aef83a488da6" />



# Kubernetes Cluster Setup (1 Master + 2 Workers) — Step‑by‑Step (Ubuntu 20.04+)

---

## 0) Inventory & Assumptions

* OS: Ubuntu 20.04/22.04 (all nodes)
* Users: `ubuntu` with passwordless sudo on all nodes
* Network: nodes can reach each other; unique hostnames
* Example IPs/hostnames (replace with yours):

  * `192.168.1.10 master`
  * `192.168.1.11 worker1`
  * `192.168.1.12 worker2`
* Pod CIDR: `192.168.0.0/16` (Calico default-friendly)

**Update /etc/hosts on all nodes** (optional but recommended):

```bash
sudo tee -a /etc/hosts >/dev/null <<EOF
192.168.1.10 master
192.168.1.11 worker1
192.168.1.12 worker2
EOF
```

---

## 1) Passwordless SSH (master ➜ workers)

On the **master**:

```bash
ssh-keygen -t rsa -b 4096 -C "ubuntu@k8s"    # press Enter for defaults
ssh-copy-id ubuntu@192.168.1.11
ssh-copy-id ubuntu@192.168.1.12
```

Verify:

```bash
ssh ubuntu@192.168.1.11 hostname
ssh ubuntu@192.168.1.12 hostname
```

---

## 2) Passwordless sudo for `ubuntu`

On **each node** (master + workers):

```bash
groups ubuntu
# expect: ubuntu : ubuntu adm cdrom sudo dip lxd
```

Enable passwordless sudo:

```bash
sudo visudo
# add at the end:
# ubuntu ALL=(ALL) NOPASSWD:ALL
```

Test from master:

```bash
ssh ubuntu@192.168.1.11 "sudo whoami"   # expect: root
```

---

## 3) System Prep (run on **each node**)

```bash
# Disable swap (runtime + persist)
sudo swapoff -a
sudo sed -i '/\sswap\s/ s/^/#/' /etc/fstab

# Kernel modules
printf "overlay\nbr_netfilter\n" | sudo tee /etc/modules-load.d/k8s.conf
sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl for Kubernetes networking
sudo tee /etc/sysctl.d/k8s.conf >/dev/null <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Tools & containerd
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
sudo apt-get install -y containerd

# containerd default config + systemd cgroup
defaults_file=/etc/containerd/config.toml
sudo mkdir -p /etc/containerd
containerd config default | sudo tee $defaults_file >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' $defaults_file
sudo systemctl enable --now containerd
```

---

## 4) Install Kubernetes Components (all nodes)

```bash
# Add Kubernetes apt repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubelet/kubeadm/kubectl
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## 5) Initialize the Control Plane (master only)

```bash
# Choose a Pod CIDR compatible with Calico
POD_CIDR=192.168.0.0/16

# Reset if re-running
sudo kubeadm reset -f

# Initialize
sudo kubeadm init --pod-network-cidr=$POD_CIDR
```

After `kubeadm init` completes, set up kubectl for the `ubuntu` user on the master:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**Save the `kubeadm join ...` command** printed at the end (you’ll need it for the workers). If you lose it, regenerate later with:

```bash
kubeadm token create --print-join-command
```

---

## 6) Install Calico CNI (master only)

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

(Optional) Watch system pods come up:

```bash
kubectl get pods -n kube-system -w
```

---

## 7) Join Worker Nodes (run on each worker)

On **each worker** node, run the **join command** from Step 5. It looks like:

```bash
sudo kubeadm join 192.168.1.10:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

If the token expired, regenerate on the master:

```bash
kubeadm token create --print-join-command
```

---

## 8) Verify the Cluster (master)

```bash
kubectl get nodes
kubectl get pods -A
```

Expected:

```
NAME      STATUS   ROLES           AGE   VERSION
master    Ready    control-plane   ✱m    v1.31.3
worker1   Ready    <none>          ✱m    v1.31.3
worker2   Ready    <none>          ✱m    v1.31.3
```

---

## 9) (Optional) ufw / firewall ports

If `ufw` is enabled, open Kubernetes ports or disable ufw during setup:

```bash
sudo ufw disable   # or add rules per Kubernetes docs
```

