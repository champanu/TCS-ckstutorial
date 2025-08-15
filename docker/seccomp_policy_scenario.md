
<img width="2542" height="1000" alt="image" src="https://github.com/user-attachments/assets/2661b264-6e82-4667-9a28-f91857bd9d1f" />

# Scenario: Seccomp Policy to Restrict Dangerous Syscalls

## Goal

- Prevent container processes from performing **dangerous or sensitive operations**: mounting, changing permissions, deleting files, creating hardlinks, or querying disk space.
- Use Docker’s **seccomp JSON profile** to enforce syscall restrictions.

---

## Step 1: Create a Seccomp Profile

Create a file `seccomp-restrict.json` with the following content:

```json
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "syscalls": [
    { "name": "mount", "action": "SCMP_ACT_ERRNO" },
    { "name": "chmod", "action": "SCMP_ACT_ERRNO" },
    { "name": "unlink", "action": "SCMP_ACT_ERRNO" },
    { "name": "link", "action": "SCMP_ACT_ERRNO" },
    { "name": "statfs", "action": "SCMP_ACT_ERRNO" }
  ]
}
```

**Explanation:**

- `defaultAction: ALLOW` → all other syscalls are allowed.
- Each syscall in `syscalls` → denied (`SCMP_ACT_ERRNO` returns error).
- `statfs` is used by `df -h` internally to get filesystem info.

---

## Step 2: Run a Container with the Seccomp Profile

```bash
docker run --rm -it --security-opt seccomp=seccomp-restrict.json alpine sh
```

---

## Step 3: Test Restricted Operations

1. Try `mount`:

```bash
mount | grep /tmp
```

- Output: `operation not permitted` 

2. Try `chmod`:

```bash
chmod 777 testfile
```

- Output: `Operation not permitted` 

3. Try `unlink`:

```bash
rm testfile
```

- Output: `Operation not permitted` 

4. Try `link`:

```bash
ln testfile testlink
```

- Output: `Operation not permitted` 

5. Try `df -h`:

```bash
df -h
```

- Output: Error or limited info, blocked by `statfs` 

---

## Step 4: Explanation

- **Seccomp** filters syscalls, not commands.
- Even root inside the container **cannot perform restricted syscalls**.
- Helps prevent container escapes, accidental damage, or malicious activity.

---

## Summary Table

| Syscall | Command Example  | Result with Seccomp Policy |
| ------- | ---------------- | -------------------------- |
| mount   | `mount`          | Blocked                    |
| chmod   | `chmod 777 file` | Blocked                    |
| unlink  | `rm file`        | Blocked                    |
| link    | `ln file link`   | Blocked                    |
| statfs  | `df -h`          | Blocked / limited          |

