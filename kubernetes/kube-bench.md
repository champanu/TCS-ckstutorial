1. **Directly with CLI on a node**
2. **As a pod inside the cluster**

Here’s a clear step-by-step:

---

## 1. Run kube-bench with CLI on the node

`kube-bench` checks Kubernetes security configuration against the [CIS Benchmarks](https://www.cisecurity.org/benchmark/kubernetes).

### Install on Node

```bash
# Download latest release
curl -L https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_$(uname -s)_$(uname -m).tar.gz -o kube-bench.tar.gz

# Extract
tar -xvf kube-bench.tar.gz

# Move binary
sudo mv kube-bench /usr/local/bin/
```

### Run Check

```bash
# Check master (control plane)
kube-bench run --targets=master

# Check node
kube-bench run --targets=node

# Full run
kube-bench
```

By default it detects Kubernetes version and runs CIS tests accordingly.

---

## 2. Run kube-bench as a Pod in the Cluster

This is useful when you **don’t have direct access to nodes**.

### Deploy using Aqua’s manifest

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
```

This creates a **Job** that runs kube-bench on each node.

### Check Job status

```bash
kubectl get jobs -n kube-bench
kubectl get pods -n kube-bench
```

### View Results

```bash
# Get pod name
kubectl get pods -n kube-bench

# View logs of kube-bench run
kubectl logs <kube-bench-pod-name> -n kube-bench
```

---

## 3. Run kube-bench as a DaemonSet

If you want kube-bench to run on **all nodes automatically**:

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-aks.yaml   # For AKS
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-gke.yaml   # For GKE
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-eks.yaml   # For EKS
```

Or create your own DaemonSet:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-bench
  namespace: kube-bench
spec:
  selector:
    matchLabels:
      name: kube-bench
  template:
    metadata:
      labels:
        name: kube-bench
    spec:
      hostPID: true
      hostNetwork: true
      containers:
        - name: kube-bench
          image: aquasec/kube-bench:latest
          command: ["kube-bench", "run", "--json"]
          volumeMounts:
            - name: var-lib-kubelet
              mountPath: /var/lib/kubelet
              readOnly: true
            - name: etc-systemd
              mountPath: /etc/systemd
              readOnly: true
            - name: etc-kubernetes
              mountPath: /etc/kubernetes
              readOnly: true
      restartPolicy: Never
      volumes:
        - name: var-lib-kubelet
          hostPath:
            path: /var/lib/kubelet
        - name: etc-systemd
          hostPath:
            path: /etc/systemd
        - name: etc-kubernetes
          hostPath:
            path: /etc/kubernetes
```

---

**Summary:**

* **CLI on Node** → Install binary, run manually.
* **As Pod/Job** → Deploy kube-bench job from Aqua’s repo.
* **As DaemonSet** → Continuous scan on all nodes.

---
