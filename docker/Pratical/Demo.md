# End-to-End Docker Networking, Security & Resource Limits Lab

## 1. Objective
We will:
- Create **two isolated networks**:  
  - `qa-network` → `192.168.100.0/24`  
  - `dev-network` → `192.168.200.0/24`  
- Launch **4 containers in each network** with **no root privileges**.
- Restrict CPU & Memory:
  - Default (if not specified): CPU = 50ms, Memory = 25m
  - dev1: min CPU = 200ms, Memory = 50m
  - dev2 & dev3: share CPU, Memory = 50m each
  - Same rule for qa2 & qa3
  - One "free" container in each network without explicit CPU/mem — will get defaults
- Block communication from `qa1` and `dev1` to other containers in their network.
- Use **bind mount** for one container in each network.
- Use **named volume** for another container in each network.
- Apply **userns-remap** and **no-new-privileges**.

---

## 2. Pre-setup – Enable `userns-remap`

```bash
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "userns-remap": "default"
}
EOF

sudo systemctl restart docker
````

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

```bash
sudo mkdir -p /srv/hostdata
echo "Host data file" | sudo tee /srv/hostdata/info.txt

docker volume create qa-volume
docker volume create dev-volume
```

---

## 5. Launch Containers in QA Network

```bash
# qa1: Bind mount + default CPU/mem (50ms, 25m)
docker run -d --name qa1 \
  --network qa-network \
  --security-opt no-new-privileges \
  --cpu-period=100000 --cpu-quota=50000 \
  --memory=25m \
  -v /srv/hostdata:/data \
  alpine sleep infinity

# qa2: Named volume + shared CPU/mem (50m)
docker run -d --name qa2 \
  --network qa-network \
  --security-opt no-new-privileges \
  --cpu-shares=512 \
  --memory=50m \
  -v qa-volume:/app \
  alpine sleep infinity

# qa3: Shared CPU/mem (50m)
docker run -d --name qa3 \
  --network qa-network \
  --security-opt no-new-privileges \
  --cpu-shares=512 \
  --memory=50m \
  alpine sleep infinity

# qa4: Free container (default CPU/mem)
docker run -d --name qa4 \
  --network qa-network \
  --security-opt no-new-privileges \
  --cpu-period=100000 --cpu-quota=50000 \
  --memory=25m \
  alpine sleep infinity
```

---

## 6. Launch Containers in DEV Network

```bash
# dev1: Bind mount + min CPU/mem
docker run -d --name dev1 \
  --network dev-network \
  --security-opt no-new-privileges \
  --cpu-period=100000 --cpu-quota=200000 \
  --memory=50m \
  -v /srv/hostdata:/data \
  alpine sleep infinity

# dev2: Named volume + shared CPU/mem
docker run -d --name dev2 \
  --network dev-network \
  --security-opt no-new-privileges \
  --cpu-shares=512 \
  --memory=50m \
  -v dev-volume:/app \
  alpine sleep infinity

# dev3: Shared CPU/mem
docker run -d --name dev3 \
  --network dev-network \
  --security-opt no-new-privileges \
  --cpu-shares=512 \
  --memory=50m \
  alpine sleep infinity

# dev4: Free container (default CPU/mem)
docker run -d --name dev4 \
  --network dev-network \
  --security-opt no-new-privileges \
  --cpu-period=100000 --cpu-quota=50000 \
  --memory=25m \
  alpine sleep infinity
```

---

## 7. Block Communication for Only One Container in Each Network

Get container IPs:

```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' qa1
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dev1
```

Assume:

```
qa1 → 192.168.100.10
dev1 → 192.168.200.10
```

Apply iptables rules:

```bash
sudo iptables -I DOCKER-USER -s 192.168.100.10 -d 192.168.100.0/24 -j DROP
sudo iptables -I DOCKER-USER -s 192.168.200.10 -d 192.168.200.0/24 -j DROP
```

---

## 8. Test Isolation

```bash
docker exec -it qa1 ping -c 2 qa2   # Should fail
docker exec -it qa2 ping -c 2 qa3   # Should work
docker exec -it dev1 ping -c 2 dev3 # Should fail
docker exec -it dev2 ping -c 2 dev4 # Should work
```

---

## 9. Test CPU/Memory Limits

```bash
docker stats
```

Check:

* `qa1`, `qa4`, `dev4` → CPU 50ms, mem 25m
* `dev1` → CPU 200ms, mem 50m
* `qa2`, `qa3`, `dev2`, `dev3` → shared CPU (512 shares each), mem 50m

---

## 10. Test Volumes

Host bind mount:

```bash
docker exec qa1 cat /data/info.txt
docker exec dev1 cat /data/info.txt
```

Named volumes:

```bash
docker exec qa2 sh -c 'echo "QA Volume Data" > /app/qa.txt'
docker exec dev2 sh -c 'echo "DEV Volume Data" > /app/dev.txt'
```

---

## 11. Cleanup

```bash
docker rm -f qa1 qa2 qa3 qa4 dev1 dev2 dev3 dev4
docker network rm qa-network dev-network
docker volume rm qa-volume dev-volume
sudo iptables -D DOCKER-USER -s 192.168.100.10 -d 192.168.100.0/24 -j DROP
sudo iptables -D DOCKER-USER -s 192.168.200.10 -d 192.168.200.0/24 -j DROP
```

---

## 12. Key Points

* **Default limits applied manually** when not specified.
* **Per-container blocking** via `iptables` instead of `icc=false`.
* **Shared CPU** via `--cpu-shares` for paired containers.
* **Bind mount + named volume** for persistence.
* **`userns-remap` + no-new-privileges** for security.
