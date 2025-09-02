# Default Capabilities in Kubernetes

## What are Linux Capabilities?

Linux breaks **root privileges** into smaller privileges called *capabilities* (e.g., `NET_ADMIN`, `SYS_ADMIN`).
Kubernetes allows you to **add** or **drop** capabilities for a container using `securityContext.capabilities`.

---

## Default Capabilities in Kubernetes

If not explicitly modified, containers in Kubernetes inherit the **Docker/CRI defaults**.

By default, the following **13 capabilities are enabled**:

* `CHOWN` → change file ownership
* `DAC_OVERRIDE` → ignore file read/write/execute permission checks
* `FSETID` → set file set-user-ID and set-group-ID bits
* `FOWNER` → bypass permission checks on operations that normally require file ownership
* `MKNOD` → create special files using `mknod`
* `NET_RAW` → use raw sockets (needed for tools like `ping`)
* `SETGID` → make arbitrary manipulations of process GIDs
* `SETUID` → make arbitrary manipulations of process UIDs
* `SETFCAP` → set file capabilities
* `SETPCAP` → modify process capabilities
* `NET_BIND_SERVICE` → bind to ports < 1024
* `SYS_CHROOT` → use `chroot()`
* `KILL` → send signals to processes belonging to others
* `AUDIT_WRITE` → write records to kernel auditing log

All other capabilities (e.g., `SYS_ADMIN`, `NET_ADMIN`, `SYS_MODULE`) are **not granted by default**.

---

## How to Check Capabilities Inside a Pod

Run a test pod:

```bash
kubectl run test --rm -it --image=ubuntu -- bash
```

Install tools:

```bash
apt-get update && apt-get install -y libcap2-bin
```

Check current capabilities:

```bash
capsh --print
```

---

## Example: Dropping a Capability

You can restrict pods further by dropping capabilities:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: no-net-raw
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      capabilities:
        drop: ["NET_RAW"]
```

---

✅ **Summary**

* Kubernetes defaults to a **restricted capability set** (13 capabilities).
* You can **add more** (not recommended for security) or **drop further** (best practice).

---

