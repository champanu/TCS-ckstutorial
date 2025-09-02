
# 1. Trivy CLI (on local machine or node)

### Install Trivy

```bash
# Debian/Ubuntu
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
```

### Run a Scan

```bash
# Scan an image
trivy image nginx:1.21

# Scan a local filesystem
trivy fs .

# Scan a Kubernetes config file
trivy config k8s-deployment.yaml
```

You’ll get a list of vulnerabilities, misconfigurations, and severity levels.

---

# 2. Trivy as Pod/Job in Kubernetes
## (a) Install with Helm (Recommended)

```bash
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
helm install trivy aqua/trivy-operator -n trivy-system --create-namespace
```

This deploys **Trivy Operator** (runs scans continuously inside the cluster).
It will create **CustomResourceDefinitions (CRDs)** like `VulnerabilityReports`, `ConfigAuditReports`, etc.

Check reports:

```bash
kubectl get vulnerabilityreports -A
kubectl get configauditreports -A
```

---

## (b) Run Trivy as a one-time Job (like kube-bench demo)

YAML example (`trivy-job.yaml`):

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: trivy-scan
  namespace: trivy-demo
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: trivy
        image: aquasec/trivy:latest
        args:
          - image
          - nginx:1.21
```

Apply it:

```bash
kubectl create namespace trivy-demo
kubectl apply -f trivy-job.yaml
```

Check results:

```bash
kubectl logs -n trivy-demo job/trivy-scan
```

---


**Summary:**

* **CLI:** `trivy image nginx:1.21` → Quick scan.
* **Job in K8s:** Run on-demand scans for images/resources.
* **Operator in K8s:** Continuous scanning of workloads, configs, and clusters.

---

