# Kubernetes etcd Backup & Restore Demo

This demo shows how to:
1. Backup etcd
2. Simulate etcd destruction
3. Restore etcd from backup

> **Note:** This demo assumes a single-node Kubernetes control plane. Adjust paths and commands for multi-node clusters.

---

## 1. Check etcd Status

```bash
ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
````

---

## 2. Backup etcd

Create a snapshot of etcd:

```bash
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

Check snapshot:

```bash
ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-snapshot.db
```

---

## 3. Simulate etcd Destruction

**WARNING:** This will destroy the Kubernetes cluster state. Only do in a test environment.

```bash
sudo systemctl stop kube-apiserver
sudo systemctl stop etcd

# Remove etcd data directory
sudo rm -rf /var/lib/etcd
```

---

## 4. Restore etcd from Snapshot

```bash
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-snapshot.db \
  --data-dir=/var/lib/etcd \
  --name <ETCD_NODE_NAME> \
  --initial-cluster <ETCD_NODE_NAME>=https://127.0.0.1:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls https://127.0.0.1:2380
```

---

## 5. Restart etcd and Kubernetes API Server

```bash
sudo systemctl start etcd
sudo systemctl start kube-apiserver
```

Verify cluster is healthy:

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 6. Notes

* Always keep etcd snapshots **off-node** for safety.
* For multi-node clusters, restore must follow **etcd multi-node restore procedures**.
* Automate backups with a cron job or use tools like **Velero** for full cluster backup.

```

