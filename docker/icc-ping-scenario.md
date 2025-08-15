
<img width="2102" height="1054" alt="image" src="https://github.com/user-attachments/assets/30146b1e-8243-4547-ac7f-5860857e1957" />


---

# Inter-Container Communication (Ping Test) Scenario

## Goal

* Demonstrate two Docker containers communicating with each other using `ping`.
* Show that containers can reach each other via a **custom network**.
* Demonstrate how enabling Docker’s `icc` (inter-container communication) setting can **block** communication **default-network (docker 0)**

---

## **Step 1: Create a Custom Docker Network**

```bash
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  dev-network
```

* `--driver bridge` → Default Docker bridge mode.
* `--subnet` / `--gateway` → Assign custom IP range.

---

## **Step 2: Run Container 1**

```bash
docker run -dit --name dev-container1 --network dev-network ubuntu
docker exec -it dev-container1 bash
apt-get update && apt-get install -y iputils-ping
```

* `-dit` → Detached + Interactive + Terminal.
* Install `iputils-ping` so we can test connectivity.

---

## **Step 3: Run Container 2**

```bash
docker run -dit --name dev-container2 --network dev-network ubuntu
docker exec -it dev-container2 bash
apt-get update && apt-get install -y iputils-ping
```

---

## **Step 4: Test Communication**

1. From **dev-container1**, ping **dev-container2**:

```bash
docker exec -it dev-container1 bash
ping -c 3 <IP-of-dev-container2>
```

Example output:

```
PING dev-container2 (192.168.100.3): 56 data bytes
64 bytes from 192.168.100.3: seq=0 ttl=64 time=0.123 ms
...
```

Success → Containers on the same network can communicate.

---

## **Step 5: Block Communication Using `icc` in Default Docker0**

By default, `icc` is enabled (`true`), allowing all containers on a default bridge network to talk to each other.

To **block inter-container communication**:

1. Edit `/etc/docker/daemon.json`:

```bash
{
  "icc": false
}
```

2. Restart Docker:

```bash
systemctl daemon-reload
systemctl restart docker
```

3. Recreate the network and containers:

```bash

#docker run -dit --name container1 ubuntu

#docker run -dit --name container2 ubuntu
```

4. Install ping in both containers:

```bash
docker exec -it container1 bash
apt-get update && apt-get install -y iputils-ping
```

5. Test connectivity:

```bash
ping -c 3 <IP-of-container2>
```

Expected output:

```
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
--- 172.17.0.3 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2028ms
```

Fail → Communication blocked between containers in default Docker0 Network.

---

## **Summary Table – Before & After `icc=false`**

| Container      | Network     | Container      | Can Ping Other Container | `icc=false` Behavior |
| -------------- | ----------- | ---------------| ------------------------ | ------------------- |
| dev-container1 | dev-network | dev-container2 | Yes                      |  No effect          |
| dev-container2 | dev-network | dev-container1 | Yes                      |  No effect          |
| container1     | docker 0    | container2     | Yes                      |  No                 |

---
