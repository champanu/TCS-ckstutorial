# Kubernetes RBAC Demo: Two Users, One Namespace

This demo shows how to create **two users**, a **namespace**, and assign different permissions:
- `user1` → can **create Pods and Services**.
- `user2` → can **read only**, cannot create resources.

---

## 1. Create a Namespace
```bash
kubectl create namespace demo-ns
````

---

## 2. Create Users (Client Certificates)

### Generate private key and CSR for `Dan` and `Joe`

```bash
# user1
openssl genrsa -out Dan.key 2048
openssl req -new -key user1.key -out Dan.csr -subj "/CN=Dan/O=demo-group"

# user2
openssl genrsa -out Joe.key 2048
openssl req -new -key Joe.key -out Joe.csr -subj "/CN=Joe/O=demo-group"
```

### Sign CSRs with cluster CA

```bash
# Dan
openssl x509 -req -in Dan.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out Dan.crt -days 365

# Joe
openssl x509 -req -in Joe.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out user2.crt -days 365
```

---

## 3. Create kubeconfig for each user

```bash
# Dan
kubectl config set-credentials Dan --client-certificate=Dan.crt --client-key=Dan.key --embed-certs=true
kubectl config set-context Dan-context --cluster=kubernetes --namespace=demo-ns --user=Dan

# user2
kubectl config set-credentials Joe --client-certificate=Joe.crt --client-key=Joe.key --embed-certs=true
kubectl config set-context Joe-context --cluster=kubernetes --namespace=demo-ns --user=Joe
```

---

## 4. Create Roles

### Role for `Dan` (can create Pods/Services)

```yaml
# role-creator.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: demo-ns
  name: pod-service-creator
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "update", "delete"]
```

```bash
kubectl apply -f role-creator.yaml
```

### Role for `Joe` (read-only)

```yaml
# role-reader.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: demo-ns
  name: pod-service-reader
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
```

```bash
kubectl apply -f role-reader.yaml
```

---

## 5. Bind Roles to Users

### Bind role to `Dan`

```yaml
# rolebinding-creator.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-creator
  namespace: demo-ns
subjects:
- kind: User
  name: Dan
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-service-creator
  apiGroup: rbac.authorization.k8s.io
```

### Bind role to `Joe`

```yaml
# rolebinding-reader.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-reader
  namespace: demo-ns
subjects:
- kind: User
  name: Joe
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-service-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f rolebinding-creator.yaml
kubectl apply -f rolebinding-reader.yaml
```

---

## 6. Test Access

```bash
# Switch to Dan
kubectl --context=Dan-context get pods
kubectl --context=Dan-context run nginx --image=nginx

# Switch to Joe
kubectl --context=Joe-context get pods
kubectl --context=Joe-context run nginx --image=nginx   # Should fail
```

**Expected Result:**

* `Dan` → can create and list Pods/Services.
* `Joe` → can only read/list, cannot create resources.

```
---

