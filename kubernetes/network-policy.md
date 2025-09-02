# 

This demo sets up **3 namespaces** with Cilium Network Policies:

* `ns-allow-a` ↔ `ns-allow-b` can communicate **via services**
* `ns-deny` is **completely isolated**

---

## Create Namespaces

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ns-allow-a
---
apiVersion: v1
kind: Namespace
metadata:
  name: ns-allow-b
---
apiVersion: v1
kind: Namespace
metadata:
  name: ns-deny
```

---

## Deploy Sample Pods + Services

### `ns-allow-a`

```yaml
apiVersion: v1
kind: Deployment
metadata:
  name: nginx-a
  namespace: ns-allow-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-a
  template:
    metadata:
      labels:
        app: nginx-a
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx-a
  namespace: ns-allow-a
spec:
  selector:
    app: nginx-a
  ports:
  - port: 80
    targetPort: 80
```

### `ns-allow-b`

```yaml
apiVersion: v1
kind: Deployment
metadata:
  name: nginx-b
  namespace: ns-allow-b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-b
  template:
    metadata:
      labels:
        app: nginx-b
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx-b
  namespace: ns-allow-b
spec:
  selector:
    app: nginx-b
  ports:
  - port: 80
    targetPort: 80
```

### `ns-deny`

```yaml
apiVersion: v1
kind: Deployment
metadata:
  name: nginx-deny
  namespace: ns-deny
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-deny
  template:
    metadata:
      labels:
        app: nginx-deny
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx-deny
  namespace: ns-deny
spec:
  selector:
    app: nginx-deny
  ports:
  - port: 80
    targetPort: 80
```

---

## Cilium Network Policies

### Allow `ns-allow-a` → `ns-allow-b`

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-a-to-b-service
  namespace: ns-allow-a
spec:
  endpointSelector: {}
  ingress:
  - fromEndpoints:
    - matchLabels:
        io.kubernetes.pod.namespace: ns-allow-b
  egress:
  - toEndpoints:
    - matchLabels:
        io.kubernetes.pod.namespace: ns-allow-b
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
```

### Allow `ns-allow-b` → `ns-allow-a`

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-b-to-a-service
  namespace: ns-allow-b
spec:
  endpointSelector: {}
  ingress:
  - fromEndpoints:
    - matchLabels:
        io.kubernetes.pod.namespace: ns-allow-a
  egress:
  - toEndpoints:
    - matchLabels:
        io.kubernetes.pod.namespace: ns-allow-a
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
```

### Deny-all in `ns-deny`

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: deny-all
  namespace: ns-deny
spec:
  endpointSelector: {}
  ingress: []
  egress: []
```

---

## Testing

From **`ns-allow-a` → `ns-allow-b`**:

```bash
kubectl exec -n ns-allow-a deploy/nginx-a -- \
  curl -s <cluster_ip>
```

Works

From **`ns-allow-b` → `ns-allow-a`**:

```bash
kubectl exec -n ns-allow-b deploy/nginx-b -- \
  curl -s <cluster_ip>
```

Works

From **`ns-deny` → any service**:

```bash
kubectl exec -n ns-deny deploy/nginx-deny -- \
  curl -s <cluster_ip>
```

Blocked

---
