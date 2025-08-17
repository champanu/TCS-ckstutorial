<img width="1840" height="996" alt="image" src="https://github.com/user-attachments/assets/fbc410a0-fac8-4c20-bd12-c2638827744e" />


<img width="2514" height="992" alt="image" src="https://github.com/user-attachments/assets/e496c8b1-f37b-4d97-891b-7191847cf695" />


1. **Non-Secure Remote Docker (just TCP without TLS)**
2. **Secure Remote Docker (TLS with certificates)**

How to **test insecure vs secure setup step-by-step**.

---

# Remote Docker Daemon over TCP (Non-Secure & Secure with TLS)

This guide shows how to configure Docker Engine to allow **remote client access over TCP** in two ways:

* **Part 1:** Non-Secure (testing only, NOT recommended in production)
* **Part 2:** Secure with TLS Certificates (recommended way)

---

## Use Case

* Enable remote Docker management for **CI/CD, dev teams, or automation tools**.
* Understand the difference between **insecure TCP (dangerous)** vs **secure TLS (safe)** access.

---

# Part 1: Non-Secure Remote Docker (TCP 2376)

**testing only**. Do not use in production.

### 1. Configure Docker Service

Edit `docker.service` file:

```bash
```
vim /lib/systemd/system/docker.service
Add:

```ini
[Service]
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
         |
         |To
         |
ExecStart=/usr/bin/dockerd -H unix://var/run/docker.sock -H tcp://0.0.0.0:2376 -H fd:// --containerd=/run/containerd/containerd.sock
```

### 2. Restart Docker

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Verify Docker is listening:

```bash
netstat -pant | grep 2376
```

---

### 3. On Client (No TLS)

```bash
sudo apt update
sudo apt install docker-cli -y
```

Set environment:

```bash
export DOCKER_HOST=tcp://<HOST-SERVER-IP>:2376
docker info   # Works without TLS
```

Run a container remotely:

```bash
docker container run -d --name test-nonsecure ubuntu sleep 60
```

---

 **Result:** Client can control host **without authentication**.
 **Risk:** Anyone on the network can take over your Docker host.

---

# Part 2: Secure Remote Docker with TLS

Now we fix the above by adding **TLS authentication**.

---

### 1. Generate Certificates on Host

Run the certificate creation script:

```bash
./generatecert.sh
ls -l docker-certs/
```

You should see:

* `ca.pem`
* `server-cert.pem`
* `server-key.pem`
* `cert.pem`
* `key.pem`

---

### 2. Configure Docker with TLS

Edit override:

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d (if not exist)
sudo vim /etc/systemd/system/docker.service.d/override.conf
```

Add:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --tlsverify \
  --tlscacert=/home/ubuntu/docker-certs/ca.pem \
  --tlscert=/home/ubuntu/docker-certs/server-cert.pem \
  --tlskey=/home/ubuntu/docker-certs/server-key.pem \
  -H tcp://0.0.0.0:2376 \
  -H unix:///var/run/docker.sock
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Verify TLS listener:

```bash
netstat -pant | grep 2376
```

---

### 3. On Client (With TLS)

Install Docker CLI:

```bash
sudo apt update
sudo apt install docker-cli -y
```

Copy certs from host:

```bash
mkdir -p /opt/docker_cert
scp ubuntu@<HOST-SERVER-IP>:/home/ubuntu/docker-certs/{ca.pem,cert.pem,key.pem} /opt/docker_cert/
```

---

### 4. Configure Client for TLS

```bash
export DOCKER_HOST=tcp://<HOST-SERVER-IP>:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/opt/docker_cert
```

Check:

```bash
docker info   # Works securely with TLS
```

Run a container securely:

```bash
docker container run -d --name test-secure ubuntu sleep 60
```

---

### 5. Test Secure vs Insecure

1. **Unset TLS (should fail):**

```bash
unset DOCKER_TLS_VERIFY
unset DOCKER_CERT_PATH
docker info   # fails
```

2. **Set TLS (should succeed):**

```bash
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/opt/docker_cert
docker info  # succeeds
```

---

## Summary

* **Part 1 (Non-Secure):** Remote Docker works, but **anyone can connect**.
* **Part 2 (Secure):** Only clients with valid TLS certs can connect.
