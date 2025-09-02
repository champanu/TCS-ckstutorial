
# Use Case: Role + RoleBinding + ServiceAccount in a Pod

## Scenario

A developer wants a Pod to **list ConfigMaps** in a specific namespace (`demo-ns`).
By default, Pods run with a ServiceAccount **default** that has **no extra permissions**.
We will:

1. Create a **ServiceAccount**.
2. Define a **Role** with limited permissions.
3. Bind the Role to the ServiceAccount via a **RoleBinding**.
4. Run a Pod that uses this ServiceAccount.

---

## Step 1: Create Namespace

```bash
kubectl create namespace demo-ns
```

---

## Step 2: Create a ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: demo-sa
  namespace: demo-ns
```

Apply:

```bash
kubectl apply -f sa.yaml
```

---

## Step 3: Create a Role

This Role allows **get, list, watch** only for ConfigMaps.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-reader
  namespace: demo-ns
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
```

---

## Step 4: Create a RoleBinding

Bind the `configmap-reader` Role to the `demo-sa` ServiceAccount.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-configmaps
  namespace: demo-ns
subjects:
- kind: ServiceAccount
  name: demo-sa
  namespace: demo-ns
roleRef:
  kind: Role
  name: configmap-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## Step 5: Run a Pod with the ServiceAccount

Pod definition:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-checker
  namespace: demo-ns
spec:
  serviceAccountName: demo-sa
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
```

---

## Step 6: Test Permissions

Exec into the pod:

```bash
kubectl exec -it configmap-checker -n demo-ns -- sh
```

Try to list configmaps:

```bash
kubectl get configmaps -n demo-ns
```

Works.

Try to list secrets:

```bash
kubectl get secrets -n demo-ns
```

Forbidden (because Role only allows ConfigMaps).

---

## Summary

* **ServiceAccount** = identity for Pods.
* **Role** = defines allowed actions on resources.
* **RoleBinding** = links Role ↔ ServiceAccount.
* Pod using that ServiceAccount gets only the **scoped permissions**.

---
