<img width="2518" height="1320" alt="image" src="https://github.com/user-attachments/assets/9987db74-add8-443f-b29e-eaad1d8285b2" />


---

# Host Machine Privilege Escalation Attempt

## Demo: How a normal Linux user or a container can try to **gain root privileges** on the host and how protections like `no-new-privileges` mitigate the risk.

---

## Unsecure Container Examples

### Mounting the Host Filesystem (`/`)

```bash
# docker run -it --rm --privileged -v /:/mnt ubuntu:24.04 bash
# ls /mnt
# cat /mnt/etc/passwd

# Escape into host root filesystem
# chroot /mnt /bin/bash
```

You’re effectively in the **host filesystem as root**.

---

### Docker Socket Escape

```bash
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock docker:24.0.5 sh
# docker ps        # works inside container
# docker run -it --rm --privileged ubuntu:24.04 bash
```

Hacker can now **launch privileged containers from inside** another container.

**Use Case:**

* Shows why **never mount `/var/run/docker.sock`** into application containers — it gives root access to the host.

---

## Step 1: Create a Normal User

```bash
# sudo useradd -ms /bin/bash testuser
# sudo passwd testuser
# su - testuser
```

* `testuser` is a **non-root user**.
* Should **not** access root files.

---

## Step 2: Try a Root-Only Command

```bash
# ls /root
```

* Output:

```
ls: cannot open directory '/root': Permission denied
```

Works as expected.

---

## Step 3: Simulate a Vulnerable Program (SUID)

Some binaries have **SUID (Set User ID)** bit set → runs with file owner’s privileges.

```bash
# sudo cp /bin/bash /tmp/bash-root
# sudo chmod +s /tmp/bash-root
```

* `/tmp/bash-root` will run **as root** even if executed by `testuser`.

---

## Step 4: Exploit the SUID Binary

As `testuser`:

```bash
# /tmp/bash-root -c "whoami"
```

* Output: `root` → **Privilege Escalation Successful**

** Use Case:**

* Demonstrates why **misconfigured SUID binaries** are dangerous in production systems.

---

## Step 5: Protect with `no-new-privileges`

`no-new-privileges` ensures a process can’t gain **higher privileges** than it started with.

### On Host

1. Start protected shell:

```bash
# sudo unshare --pid --fork --mount-proc bash
# prctl --no-new-privs
```

2. Run the same SUID binary:

```bash
# /tmp/bash-root -c "whoami"
```

* Output: `testuser` → cannot escalate to root.

---

### Inside Docker

#### Without Protection

```bash
# docker run -it --rm ubuntu:24.04 bash
# apt-get update && apt-get install -y vim-tiny
# chmod u+s /usr/bin/vim.tiny   # make vim SUID root
# su - testuser -c "vim.tiny -c '!whoami'"
```

* Output: `root` → Privilege escalation possible.

#### With `no-new-privileges`

```bash
# docker run -it --rm \
  --security-opt no-new-privileges \
  ubuntu:24.04 bash

# chmod u+s /usr/bin/vim.tiny
# su - testuser -c "vim.tiny -c '!whoami'"
```

* Output: `testuser` → Escalation blocked.

**Use Case:**

* In **Docker/Kubernetes**, adding:

  ```yaml
  securityContext:
    allowPrivilegeEscalation: false
  ```

  ensures containers cannot exploit SUID binaries to gain root.

---

## Summary Table

| Scenario                      | Result Without Protection | Result With `no-new-privileges` |
| ----------------------------- | ------------------------- | ------------------------------- |
| Normal user runs root command | Fails                     | Fails                           |
| User runs SUID binary         | Succeeds → becomes root   | Fails                           |
| Container runs SUID exploit   | Succeeds → root           | Fails                           |
| Risk                          | High                      | Low                             |

---

