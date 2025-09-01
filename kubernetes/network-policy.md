# Cilium Network Policy Demo

This demo shows how to use **Cilium Network Policies (CNPs)** to control traffic between pods in Kubernetes.

---

## Prerequisites

- A Kubernetes cluster (any kind, e.g., kind, k3s, AKS, EKS, GKE)
- Cilium installed as CNI
- `kubectl` and `cilium` CLI installed

Install Cilium CLI:

```bash
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
````

Install Cilium in your cluster:

```bash
cilium install
cilium status
```

Optional: Enable Hubble for observability:

```bash
cilium hubble enable
cilium hubble port-forward
```

---

## Setup Namespace and Pods

```bash
kubectl create namespace netdemo

kubectl run backend --image=nginx -n netdemo --labels app=backend -- sleep 3600
kubectl run frontend --image=busybox -n netdemo --labels app=frontend -- sleep 3600
kubectl run otherpod --image=busybox -n netdemo --labels app=other -- sleep 3600
```

Check pods:

```bash
kubectl get pods -n netdemo
```

---

## Test Connectivity (Before NetworkPolicy)

```bash
kubectl exec -n netdemo frontend -- wget -qO- http://backend
kubectl exec -n netdemo otherpod -- wget -qO- http://backend
```

Both pods can access the backend (default allow).

---

## reate a Cilium Network Policy (Allow Only Frontend)

```yaml
# cilium-allow-frontend.yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-frontend
  namespace: netdemo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
```

Apply the policy:

```bash
kubectl apply -f cilium-allow-frontend.yaml
```

---

## Test Connectivity (After CNP)

```bash
kubectl exec -n netdemo frontend -- wget -qO- http://backend
# Works

kubectl exec -n netdemo otherpod -- wget -qO- http://backend
#Fails
```

---

## Optional: L7 HTTP Policy

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: backend-http-policy
  namespace: netdemo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      rules:
        http:
        - method: GET
          path: /allowed
```
Only GET requests to `/allowed` are allowed.

---


Check active policies:

```bash
cilium policy get
```

---

## Key Takeaways

* Cilium uses **eBPF** for fast, identity-based networking.
* Supports **L3/L4 and L7 policies**.
* Allows **label-based, cross-namespace, and HTTP-level rules**.
* Full observability via `cilium monitor` or **Hubble UI**.

```

---
