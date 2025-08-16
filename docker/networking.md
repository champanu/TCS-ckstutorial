

<img width="1794" height="998" alt="image" src="https://github.com/user-attachments/assets/1e27cbe4-8bb1-479e-a258-2044acc63fbd" />


<img width="2102" height="1054" alt="image" src="https://github.com/user-attachments/assets/e40b2ac4-a756-4956-a625-33a1d13ef7a8" />


<img width="2102" height="1054" alt="image" src="https://github.com/user-attachments/assets/ada3f670-7fbf-4805-813f-899fb103cb50" />

---

# Scenario: Docker Networking – `none`, `bridge`, `custom bridge`, and `host`

## Goal

* Demonstrate Docker container networking modes:

  * `none` → No connectivity
  * `bridge` → Default bridge network
  * `custom bridge` → User-defined subnets (`dev-network`, `qa-network`)
  * `host` → Shares host network stack
* Show **use cases** for each type.
* Learn how to get container **IP addresses**.

---

## **Step 1: Create Custom Networks**

```bash
# Create dev-network
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  dev-network

# Create qa-network
docker network create \
  --driver bridge \
  --subnet 192.168.200.0/24 \
  qa-network
```

---

## **Step 2: Create Containers in Each Network**

```bash
# Dev containers
docker run -dit --name dev1 --network dev-network alpine sh
docker run -dit --name dev2 --network dev-network alpine sh

# QA containers
docker run -dit --name qa1 --network qa-network alpine sh
docker run -dit --name qa2 --network qa-network alpine sh
```

---

## **Step 3: Get Container IP Addresses**

```bash
# General inspect command
# docker inspect <container_name> \
  | grep "IPAddress"

# Example for dev1
# docker inspect dev1 \
  | grep "IPAddress"

# To get only the IP in clean format
# docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dev1
```

Example output:

* `dev1 → 192.168.100.2`
* `dev2 → 192.168.100.3`
* `qa1 → 192.168.200.2`
* `qa2 → 192.168.200.3`

---

## **Step 4: Test Connectivity Within Each Network**

```bash
# docker exec -ti dev1 bash 
# apk add --no-cache iputils
# ping -c 3 192.168.100.3   # dev2 IP

# docker exec -ti qa1 bash
# apk add --no-cache iputils
# ping -c 3 192.168.200.3   # qa2 IP
```

Works: Containers in the same **custom bridge** can talk.

---

## **Step 5: Test Isolation Between Networks**

```bash
# docker exec -ti dev1 bash
# ping -c 3 192.168.200.2   # qa1 IP
```

Fails: Different networks are isolated.

---

## **Step 6: none Network Example**

```bash
# docker run -dit --name isolated --network none ubuntu
# docker exec -ti isolated bash
# apt install iputils-ping `(will not able to install as no network attached)`
```

* Only `lo` (loopback) interface exists.
* No container-to-container or internet connectivity.

**Use Case:**

* Run untrusted workloads securely.
* Batch jobs with no networking needs.

---

## **Step 7: host Network Example**

```bash
# docker run -dit --name hostnet --network host ubuntu
# docker exec -ti hostnet bash
# apt update && apt install nettools*
# ip a `(Verify the host ip and Container IP)`
```

* Shares host’s network namespace.
* No separate container IP (it uses host’s IP).

Example:

```bash
# docker run -d --name web --network host nginx
```

Accessible at → `http://<host-ip>:80` (without `-p`).

**Use Case:**

* High-performance apps needing low latency.
* Monitoring tools (tcpdump, sniffers).
* Apps needing to bind directly to host ports.

---

## **Step 8: bridge (Default) Example**

```bash
# docker run -dit --name bridged1 alpine sh
# docker run -dit --name bridged2 alpine sh
```

* Joins default `bridge` network.
* Needs `-p` to be accessible from host.

**Use Case:**

* Quick tests, small apps on one host.

---

## **Step 9: custom bridge Example**

Already created → `dev-network`, `qa-network`.

**💡 Use Case:**

* Isolated environments (Dev/QA).
* Assign predictable subnets.
* Use DNS (`ping dev2` works inside `dev1`).

---

## **Summary Table**

| Network Type      | Connectivity                     | Example Use Case                                                                 |
| ----------------- | -------------------------------- | -------------------------------------------------------------------------------- |
| **none**          | Only loopback (`lo`)             | Security sandboxing, batch jobs with no networking                               |
| **bridge**        | Same bridge containers talk      | Default apps, requires `-p` to expose externally                                 |
| **custom bridge** | User-defined subnet, DNS support | Isolated environments (dev/qa), controlled IP ranges, multi-tier apps            |
| **host**          | Shares host’s network stack      | High-performance apps, monitoring tools, binding directly to host ports (80/443) |

---
