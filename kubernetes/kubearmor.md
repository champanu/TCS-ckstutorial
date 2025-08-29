
# KubeArmor: Kubernetes Runtime Security Enforcement

KubeArmor provides **policy-driven runtime protection** for containers and Kubernetes workloads.  
It helps enforce security policies such as:
- Blocking execution of sensitive binaries  
- Restricting file/directory access  
- Controlling network connections  

---

## Step 1: Install KubeArmor

Deploy using Helm:

```bash
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update

kubectl create namespace kubearmor

helm install kubearmor kubearmor/kubearmor -n kubearmor
````

Verify installation:

```bash
kubectl get pods -n kubearmor
```

---

## Step 2: Deploy a Test Application

For testing, deploy **nginx**:

```bash
kubectl run nginx --image=nginx --restart=Never
```

---

## Step 3: Apply a KubeArmor Policy

Example: **Block access to `/etc/shadow`** inside the pod.

```yaml
apiVersion: security.kubearmor.com/v1
kind: KubeArmorPolicy
metadata:
  name: block-shadow
  namespace: default
spec:
  severity: 5
  message: "Access to /etc/shadow is blocked!"
  selector:
    matchLabels:
      run: nginx
  file:
    matchPaths:
      - path: /etc/shadow
    action: Block
```

Apply policy:

```bash
kubectl apply -f block-shadow.yaml
```

---

## Step 4: Test the Policy

Login to the pod:

```bash
kubectl exec -it nginx -- bash
```

Try accessing `/etc/shadow`:

```bash
cat /etc/shadow
```

You should see access **denied** in KubeArmor logs.

Check logs:

```bash
kubectl logs -n kubearmor -l kubearmor-app=kubearmor
```

---

## Step 5: Example Policy — Block Dangerous Binaries

Block execution of **bash** inside nginx pod:

```yaml
apiVersion: security.kubearmor.com/v1
kind: KubeArmorPolicy
metadata:
  name: block-bash
  namespace: default
spec:
  severity: 5
  message: "Execution of bash is blocked!"
  selector:
    matchLabels:
      run: nginx
  process:
    matchPaths:
      - path: /bin/bash
    action: Block
```

---

## Step 6: Example Policy — Network Restriction

Block all outbound connections from nginx:

```yaml
apiVersion: security.kubearmor.com/v1
kind: KubeArmorPolicy
metadata:
  name: block-outbound
  namespace: default
spec:
  severity: 4
  message: "Outbound connections are not allowed!"
  selector:
    matchLabels:
      run: nginx
  network:
    matchProtocols:
      - protocol: tcp
    action: Block
```

---

## Step 7: Monitor Alerts in KubeArmor

Check alerts:

```bash
kubectl logs -n kubearmor -l kubearmor-app=kubearmor --tail=50
```

Or deploy **KubeArmor Relay + KubeArmor Host Policy Manager** for UI dashboards.

---

## Cleanup

Remove policies and uninstall KubeArmor:

```bash
kubectl delete -f block-shadow.yaml
kubectl delete -f block-bash.yaml
kubectl delete -f block-outbound.yaml

helm uninstall kubearmor -n kubearmor
kubectl delete namespace kubearmor
```

---

## Summary

* Installed **KubeArmor** in Kubernetes
* Created **runtime security policies** (file, process, network)
* Tested enforcement by blocking `/etc/shadow` and `/bin/bash`
* Learned how to monitor alerts via logs/UI

```
