Got it — I’ll make you a **detailed `.md` file** explaining Docker Linux capabilities, with **examples, scenarios, and security notes**.
I’ll structure it like a mini-guide so you can use it for both learning and hands-on labs.

---

````markdown
# Docker Capabilities – Guide with Scenarios

## 1. Introduction

By default, Docker containers **do not run with full root privileges**.  
Instead, the Linux kernel’s *capabilities* system is used to grant containers **a reduced set of root-like privileges**.

### Why Capabilities Matter
- They **fine-tune** permissions instead of giving *all* `root` privileges.
- They help enforce the **principle of least privilege**.
- Removing unnecessary capabilities **reduces attack surface**.

---

## 2. Viewing Capabilities

### Inside a Container
```bash
docker run --rm -it alpine:latest sh
apk add libcap
capsh --print
````

This prints:

* **Bounding set** (max allowed capabilities)
* **Effective set** (currently active capabilities)

---

## 3. Default Docker Capabilities

Docker (as of recent versions) grants these **by default**:

* `CAP_CHOWN` – Change file owner/group.
* `CAP_DAC_OVERRIDE` – Bypass file read/write/execute permission checks.
* `CAP_FSETID` – Set file UID/GID bits.
* `CAP_FOWNER` – Ignore file owner checks.
* `CAP_MKNOD` – Create special files.
* `CAP_NET_RAW` – Use raw and packet sockets.
* `CAP_SETGID` – Set GID for processes.
* `CAP_SETUID` – Set UID for processes.
* `CAP_SETFCAP` – Set file capabilities.
* `CAP_SETPCAP` – Modify process capabilities.
* `CAP_NET_BIND_SERVICE` – Bind to ports < 1024.
* `CAP_SYS_CHROOT` – Use `chroot`.
* `CAP_KILL` – Send signals to processes.
* `CAP_AUDIT_WRITE` – Write to audit logs.

---

## 4. Managing Capabilities in Docker

### Drop All Capabilities

```bash
docker run --rm -it --cap-drop ALL alpine sh
```

### Add a Specific Capability

```bash
docker run --rm -it --cap-add NET_ADMIN alpine sh
```

### Drop a Specific Capability

```bash
docker run --rm -it --cap-drop NET_RAW alpine sh
```

---

## 5. Security Risks by Capability

| Capability            | Risk Example                                                    |
| --------------------- | --------------------------------------------------------------- |
| `CAP_NET_RAW`         | Packet sniffing, ARP spoofing.                                  |
| `CAP_SYS_ADMIN`       | Almost full root — mount filesystems, modify kernel parameters. |
| `CAP_SYS_PTRACE`      | Attach to other processes, steal secrets.                       |
| `CAP_SYS_MODULE`      | Load/unload kernel modules — complete host compromise.          |
| `CAP_DAC_READ_SEARCH` | Read restricted files.                                          |

---

## 6. Scenarios & Labs

### Scenario 1 – Network Attack with `CAP_NET_RAW`

1. **Run with capability**:

   ```bash
   docker run --rm -it --cap-add NET_RAW alpine sh
   apk add iputils tcpdump
   tcpdump -i eth0
   ```

2. Observe packets inside container.

3. **Run without capability**:

   ```bash
   docker run --rm -it --cap-drop NET_RAW alpine sh
   tcpdump -i eth0
   # Should fail: Permission denied
   ```

---

### Scenario 2 – Mount Filesystem with `CAP_SYS_ADMIN`

1. **With SYS\_ADMIN**:

   ```bash
   docker run --rm -it --cap-add SYS_ADMIN alpine sh
   mkdir /mnt/test
   mount -t tmpfs tmpfs /mnt/test
   ```
2. **Without SYS\_ADMIN**:

   ```bash
   docker run --rm -it alpine sh
   mount -t tmpfs tmpfs /mnt/test
   # mount: permission denied
   ```

---

### Scenario 3 – File Permission Bypass with `CAP_DAC_OVERRIDE`

1. Create a test file on the host:

   ```bash
   echo "Secret Data" > /tmp/secret.txt
   chmod 600 /tmp/secret.txt
   ```
2. Run with capability:

   ```bash
   docker run --rm -it \
     -v /tmp:/host --cap-add DAC_OVERRIDE alpine sh
   cat /host/secret.txt
   ```
3. Without capability:

   ```bash
   docker run --rm -it \
     -v /tmp:/host --cap-drop DAC_OVERRIDE alpine sh
   cat /host/secret.txt
   # Permission denied
   ```

---

### Scenario 4 – Full Root-like Access with `--privileged`

```bash
docker run --rm -it --privileged alpine sh
# Has ALL capabilities
capsh --print
```

**Warning:** This bypasses almost all Docker isolation.

---

## 7. Recommendations

* **Drop all** and only add needed ones:

  ```bash
  docker run --cap-drop ALL --cap-add NET_BIND_SERVICE myapp
  ```
* Avoid `--privileged` unless absolutely required.
* Audit containers for unused capabilities.
* Combine with AppArmor/SELinux/seccomp for layered security.


