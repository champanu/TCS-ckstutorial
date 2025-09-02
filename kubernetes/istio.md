
# 1. Add Istio Helm Repo

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

---

# 2. Install Istio Base (CRDs + namespace)

```bash
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
```

---

# 3. Install Istiod (Control Plane)

```bash
helm install istiod istio/istiod -n istio-system --wait
```

Check:

```bash
kubectl get pods -n istio-system
```

You should see `istiod` running.

---

# 4. Install Istio Ingress Gateway

```bash
helm install istio-ingress istio/gateway -n istio-system --wait
```

Check:

```bash
kubectl get svc -n istio-system
```

You should see `istio-ingressgateway` with a **LoadBalancer** or **NodePort** IP.

---

# 5. Enable Sidecar Injection

Label your namespace (example: `default`):

```bash
kubectl label namespace default istio-injection=enabled
```

Now all Pods in that namespace will automatically get the **Envoy sidecar** injected.

---

# 6. Deploy a Sample App (Optional)

For testing, deploy something simple like nginx:

```bash
kubectl run nginx --image=nginx -n default
```

Check that sidecar is injected:

```bash
kubectl get pod nginx -o yaml | grep istio-proxy
```

---

That’s a **full Istio deployment using only Helm**.
You now have:

* **CRDs** (via `istio-base`)
* **Control plane (istiod)**
* **Ingress Gateway**

---

