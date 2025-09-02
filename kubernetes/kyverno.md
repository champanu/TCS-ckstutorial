# 1. Install Kyverno

### Option A: Using Helm (recommended)

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

### Option B: Using kubectl (manifests)

```bash
kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml
```

Check pods:

```bash
kubectl get pods -n kyverno
```

You should see Kyverno controller pods running.

---

# 2. Create a Sample Policy

Let’s enforce **"disallow privileged pods"** (a common CIS recommendation).

Save as `disallow-privileged.yaml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged
spec:
  validationFailureAction: enforce   # can be "audit" or "enforce"
  background: true
  rules:
    - name: check-privileged
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Privileged mode is not allowed."
        pattern:
          spec:
            containers:
            - securityContext:
                privileged: "false"
```

Apply:

```bash
kubectl apply -f disallow-privileged.yaml
```

---

# 3. Test the Policy

### Pod that violates policy

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
```

Apply it:

```bash
kubectl apply -f bad-pod.yaml
```

This should **fail** with:

```
error: pods "bad-pod" is forbidden: Privileged mode is not allowed.
```

### Pod that passes policy

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: good-pod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: false
```

Apply:

```bash
kubectl apply -f good-pod.yaml
```

This one should run successfully.

---

# 4. Check Policy Reports

Kyverno also generates reports:

```bash
kubectl get policyreports
kubectl get clusterpolicyreports
```

---
