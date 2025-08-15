
<img width="2102" height="1054" alt="image" src="https://github.com/user-attachments/assets/30146b1e-8243-4547-ac7f-5860857e1957" />


---

# Inter-Container Communication (Ping Test) Scenario For Default Bridge

## Goal

* Demonstrate how disabeling Docker’s `icc` (inter-container communication) setting can **block** communication in containers running in DOCKER 0 Bridge **default-network (docker 0)**

---

## **Step 1: Block Communication Using `icc` in Default Docker0**

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

3. Create containers in Docker 0:

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
| container1     | docker 0    | container2     | Yes                      |  No                 |

---
