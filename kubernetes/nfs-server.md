---

# NFS Server and Client Configuration Guide

## Overview

We will configure:

* **NFS Server** to export `/nfsvolume`
* **NFS Client** to mount it on `/shared_storage/`

---

## On NFS Server

### 1. Install NFS Packages

```bash
sudo apt update -y        # For Ubuntu/Debian
sudo apt install nfs-kernel-server -y

# For RHEL/CentOS
# sudo yum install nfs-utils -y
```

### 2. Create Export Directory

```bash
sudo mkdir -p /nfsvolume
sudo chown -R nobody:nogroup /nfsvolume
sudo chmod 777 /nfsvolume
```

### 3. Configure Exports

Edit the NFS export file:

```bash
sudo nano /etc/exports
```

Add:

```
/nfsvolume   *(rw,sync,no_subtree_check)
```

### 4. Apply Export Changes

```bash
sudo exportfs -rav
```

### 5. Start & Enable NFS Service

```bash
sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server
```

### 6. Verify Export

```bash
showmount -e
```

---

## On NFS Client

### 1. Install NFS Packages

```bash
sudo apt update -y
sudo apt install nfs-common -y

# For RHEL/CentOS
# sudo yum install nfs-utils -y
```

### 2. Create Mount Directory

```bash
sudo mkdir -p /shared_storage
```

### 3. Mount NFS Share

```bash
sudo mount <NFS_SERVER_IP>:/nfsvolume /shared_storage
```

### 4. Verify Mount

```bash
df -hT | grep nfs
```

---

##  Persistent Mount (Optional)

Edit `/etc/fstab` on the client:

```bash
sudo nano /etc/fstab
```

Add the following line:

```
<NFS_SERVER_IP>:/nfsvolume   /shared_storage   nfs   defaults   0   0
```

Apply:

```bash
sudo mount -a
```

---

## Verification

* On server: Create a file in `/nfsvolume`
* On client: File should appear in `/shared_storage`

---
