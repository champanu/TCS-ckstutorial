
# Inter-Container Communication (Ping Test) Scenario

## Goal
- Demonstrate two Docker containers communicating with each other using `ping`.  
- Show that containers can reach each other via a custom network.

---

## Step 1: Create a Docker Network
```bash
docker network create test-net
```
- `test-net` will allow containers to talk to each other.

---

## Step 2: Run Container 1
```bash
docker run -dit --name container1 --network test-net alpine sh
```
- `alpine` is a small container image.  
- `-dit` runs it in detached interactive mode with a shell.  

---

## Step 3: Run Container 2
```bash
docker run -dit --name container2 --network test-net alpine sh
```

---

## Step 4: Test Communication
1. Enter `container1`:
```bash
docker exec -it container1 sh
```

2. Ping `container2`:
```bash
ping -c 3 container2
```
- Output:
```
PING container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.123 ms
...
```
- Success → containers can communicate via `test-net`.

---

## Step 5: Security Considerations
- Only containers on the same network can ping each other.  
- Host network is isolated unless explicitly connected.  
- Combine with `userns-remap` or `no-new-privileges` for extra safety.

---

## Summary Table
| Container    | Network       | Can Ping             |
|--------------|---------------|--------------------|
| container1   | test-net      | container2 ✅       |
| container2   | test-net      | container1 ✅       |
| Host         | Not connected | Cannot ping by default |
