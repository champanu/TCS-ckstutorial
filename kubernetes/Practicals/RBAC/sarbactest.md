## 1. Create a Namespace (optional, for isolation)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo-rbac
```

---

## 2. Create a ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader
  namespace: demo-rbac
```

---

## 3. Create an RBAC Role (permissions)

This Role lets the SA **list and get pods** only.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: demo-rbac
  name: pod-reader-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

---

## 4. Bind Role to ServiceAccount

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: demo-rbac
subjects:
- kind: ServiceAccount
  name: pod-reader
  namespace: demo-rbac
roleRef:
  kind: Role
  name: pod-reader-role
  apiGroup: rbac.authorization.k8s.io
```

---

## 5. Pod using the ServiceAccount

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
  namespace: demo-rbac
spec:
  serviceAccountName: pod-reader
  containers:
  - name: curl
    image: curlimages/curl
    command: [ "sleep", "3600" ]
```

---

## 6. Test RBAC in Pod

1. Exec into the Pod:

   ```bash
   kubectl exec -n demo-rbac -it demo-pod -- sh
   ```

2. Try listing pods (allowed):

   ```bash
   curl -sSk -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
     https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/demo-rbac/pods
   ```

3. Try listing secrets (forbidden):

   ```bash
   curl -sSk -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
     https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/demo-rbac/secrets
   ```

   We should see a **403 Forbidden**, proving RBAC works.

---
