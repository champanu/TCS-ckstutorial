# Scenario: Docker Networking - none, bridge with dev-network & qa-network

## Goal

- Demonstrate Docker container networking using:
  - `none` network (no connectivity)
  - `bridge` network with two custom subnets:
    - `dev-network` → `192.168.100.0/24`
    - `qa-network` → `192.158.200.0/24`
- Create **two containers** in each custom network.

---

## Step 1: Create Custom Networks

```bash
# Create dev-network
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  dev-network

# Create qa-network
docker network create \
  --driver bridge \
  --subnet 192.158.200.0/24 \
  qa-network
```

---

## Step 2: Create Containers in Each Network

```bash
# Dev containers
docker run -dit --name dev1 --network dev-network alpine sh
docker run -dit --name dev2 --network dev-network alpine sh

# QA containers
docker run -dit --name qa1 --network qa-network alpine sh
docker run -dit --name qa2 --network qa-network alpine sh
```

---

## Step 3: Test Connectivity Within Each Network

```bash
# Inside dev1
apk add --no-cache iputils
ping -c 3 dev2

# Inside qa1
apk add --no-cache iputils
ping -c 3 qa2
```

**Result:** Containers in the same custom bridge network can communicate by name.

---

## Step 4: Test Isolation Between Networks

```bash
# Inside dev1
ping -c 3 qa1
```

**Result:** Ping fails because networks are isolated by default.

---

## Step 5: none Network Example

```bash
docker run -dit --name isolated --network none alpine sh
```

- Container has no network interface except `lo` (loopback).
- Cannot communicate with other containers or the internet.

---

## Summary Table

| Network Type | Connectivity                  | Example Use Case              |
| ------------ | ----------------------------- | ------------------------------ |
| none         | No external connectivity      | Security isolation             |
| bridge       | Same network containers talk  | Default for multi-container app|
| custom bridge| User-defined subnet/isolation | Environment separation         |

