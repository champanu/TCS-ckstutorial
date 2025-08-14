# End-to-End Docker Networking & Security Lab (Selective Communication Block)

## 1. Objective
We will:
- Create **two isolated networks**:  
  - `qa-network` → `192.168.100.0/24`  
  - `dev-network` → `192.168.200.0/24`  
- Launch **4 containers in each network** with **no root privileges**.
- Block **container-to-container communication** only for:
  - `qa1` in `qa-network`
  - `dev1` in `dev-network`
- Apply **user namespace remapping** (`--userns-remap`).
- Use **bind mount** for one container in each network.
- Use **named volume** for another container in each network.

---

## 2. Pre-setup – Enable `userns-remap`

Edit Docker daemon config:
```bash
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "userns-remap": "default"
}
EOF
````

Restart Docker:

```bash
sudo systemctl restart docker
```

---

## 3. Create Networks

```bash
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  qa-network

docker network create \
  --driver bridge \
  --subnet 192.168.200.0/24 \
  dev-network
```

---

## 4. Prepare Volumes

Host bind mount directory:

```bash
sudo mkdir -p /srv/hostdata
echo "Host data file" | sudo tee /srv/hostdata/info.txt
```

Named volumes:

```bash
docker volume create qa-volume
docker volume create dev-volume
```

---

## 5. Launch Containers in QA Network

```bash
docker run -d --name qa1 \
  --network qa-network \
  --security-opt no-new-privileges \
  -v /srv/hostdata:/data \
  alpine sleep infinity

docker run -d --name qa2 \
  --network qa-network \
  --security-opt no-new-privileges \
  -v qa-volume:/app \
  alpine sleep infinity

docker run -d --name qa3 \
  --network qa-network \
  --security-opt no-new-privileges \
  alpine sleep infinity

docker run -d --name qa4 \
  --network qa-network \
  --security-opt no-new-privileges \
  alpine sleep infinity
```

---

## 6. Launch Containers in DEV Network

```bash
docker run -d --name dev1 \
  --network dev-network \
  --security-opt no-new-privileges \
  -v /srv/hostdata:/data \
  alpine sleep infinity

docker run -d --name dev2 \
  --network dev-network \
  --security-opt no-new-privileges \
  -v dev-volume:/app \
  alpine sleep infinity

docker run -d --name dev3 \
  --network dev-network \
  --security-opt no-new-privileges \
  alpine sleep infinity

docker run -d --name dev4 \
  --network dev-network \
  --security-opt no-new-privileges \
  alpine sleep infinity
```

---

## 7. Block Communication for Only One Container in Each Network

### Get container IPs:

```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qa1
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dev1
```

Suppose results are:

```
qa1 → 192.168.100.10
dev1 → 192.168.200.10
```

### Apply iptables rules (on host):

```bash
# Block outgoing traffic from qa1 to other containers in qa-network
sudo iptables -I DOCKER-USER -s 192.168.100.10 -d 192.168.100.0/24 -j DROP

# Block outgoing traffic from dev1 to other containers in dev-network
sudo iptables -I DOCKER-USER -s 192.168.200.10 -d 192.168.200.0/24 -j DROP
```

---

## 8. Test Isolation

From `qa1`:

```bash
docker exec -it qa1 sh
ping -c 2 qa2
# Should fail
```

From `qa2`:

```bash
docker exec -it qa2 sh
ping -c 2 qa3
# Should work
```

From `dev1`:

```bash
docker exec -it dev1 sh
ping -c 2 dev3
# Should fail
```

From `dev2`:

```bash
docker exec -it dev2 sh
ping -c 2 dev4
# Should work
```

---

## 9. Test Volumes

Host bind mount:

```bash
docker exec qa1 cat /data/info.txt
docker exec dev1 cat /data/info.txt
```

Named volumes:

```bash
docker exec qa2 sh -c 'echo "QA Volume Data" > /app/qa.txt'
docker exec qa2 cat /app/qa.txt

docker exec dev2 sh -c 'echo "DEV Volume Data" > /app/dev.txt'
docker exec dev2 cat /app/dev.txt
```

---

## 10. Cleanup

```bash
docker rm -f qa1 qa2 qa3 qa4 dev1 dev2 dev3 dev4
docker network rm qa-network dev-network
docker volume rm qa-volume dev-volume
sudo iptables -D DOCKER-USER -s 192.168.100.10 -d 192.168.100.0/24 -j DROP
sudo iptables -D DOCKER-USER -s 192.168.200.10 -d 192.168.200.0/24 -j DROP
```

---

## 11. Key Security Features Used

* **Per-container network blocking** → Uses `iptables` rules in `DOCKER-USER` chain.
* **`--userns-remap`** → Maps container root to non-root UID/GID on host.
* **`--security-opt no-new-privileges`** → Prevents privilege escalation.
* **Custom bridge networks** → Isolates workloads.
* **Bind mounts & named volumes** → Persistent storage with controlled scope.


