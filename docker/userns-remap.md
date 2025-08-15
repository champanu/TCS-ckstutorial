
<img width="2542" height="1000" alt="image" src="https://github.com/user-attachments/assets/10582fe3-789f-4f61-89fd-dd339034fa88" />

# Docker User Namespace Remapping (`userns-remap`) Scenario

## Goal
- Isolate container users from host users.  
- Even if a process inside a container runs as root, it maps to a non-root user on the host, improving security.  

---

## Step 1: Understand the Problem
- By default, Docker containers run as **root inside the container**.  
- If a container is compromised, root inside the container could access host resources if misconfigured.  

Example:
```bash
docker run --rm -it ubuntu:24.04 bash
# Inside container
whoami
# Output: root
```
- Risk: Root inside the container can potentially affect the host.  

---

## Step 2: Configure User Namespace Remapping
1. Edit Docker daemon configuration `/etc/docker/daemon.json`:
```json
{
  "userns-remap": "default"
}
```
- `"default"` tells Docker to automatically map container root to a non-root user on the host.  

2. Restart Docker:
```bash
sudo systemctl restart docker
```

---

## Step 3: Verify User Namespace Remapping
Run a container:
```bash
docker run --rm -it ubuntu:24.04 bash
```
Inside container:
```bash
whoami
id
```
- Output:
```
root
uid=0(root) gid=0(root) groups=0(root)
```
- **Inside container**, still root.  
- **Outside on host**, mapped to a non-root UID (usually `100000`+).  

Check host mapping:
```bash
cat /etc/subuid
cat /etc/subgid
```
- Shows how container UIDs map to host UIDs.  

---

## Step 4: Test Security
1. Try writing to a host directory from inside the container:
```bash
mkdir /tmp/test
touch /tmp/test/file
```
- If `/tmp/test` is owned by host root, container cannot modify it.  

**Why safe:** Even if the container root tries to modify host files, it’s mapped to a non-root UID → cannot harm host.  

---

## Step 5: Combine with `no-new-privileges`
For extra security, combine `userns-remap` with `--security-opt no-new-privileges:true`:
```bash
docker run --rm --security-opt no-new-privileges:true -it ubuntu:24.04 bash
```
- Prevents privilege escalation **inside the container**.  

---

## Summary
| Feature            | Effect                                      |
|--------------------|--------------------------------------------|
| userns-remap       | Container root mapped to non-root host UID |
| no-new-privileges  | Prevents privilege escalation inside container |
| Together           | Strong isolation and reduced host risk     |
