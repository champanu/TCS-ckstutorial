
<img width="2102" height="1054" alt="image" src="https://github.com/user-attachments/assets/30146b1e-8243-4547-ac7f-5860857e1957" />

# Inter-Container Communication (Ping Test) Scenario

## Goal
- Demonstrate two Docker containers communicating with each other using `ping`.  
- Show that containers can reach each other via a custom network.
- Enable icc in docker deamon to block inter container communication
---

## Step 1: Create a Docker Network
```bash
docker network create dev-network --address 192.168.100.0/24 --gateway 192.168.200.1
```
- `dev-network` will allow containers to talk to each other.

---

## Step 2: Run Container 1
```bash
# docker run -dit --name dev-container1 --network dev-network ubuntu
# docker attach <dev-container1>
# apt get update
# apt install iputils-ping
#CTRL+P CTRL+Q

```
- `ubuntu` is container image.  
- `-dit` runs it in detached interactive mode.  

---

## Step 3: Run Container 2
```bash
# docker run -dit --name dev-container2 --network dev-network ubuntu
# docker attach <dev-container2>
# apt get update
# apt install iputils-ping
#CTRL+P CTRL+Q
```
---

## Step 4: Test Communication
1. Enter `dev-container1`:
```bash
# docker exec -it dev-container1 bash
```

2. Ping `dev-container2`:
```bash
# ping -c 3 < ip of dev-container2>
```
- Output:
```
PING dev-container2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.123 ms
...
```
- Success → containers can communicate via `dev-network`.

---

## Step 5: Security Considerations
- Only containers on the same network can ping each other.  
- Host network is isolated unless explicitly connected.  
- Combine with `userns-remap` or `no-new-privileges` for extra safety.

---

## Lets Block Container Communication within the dev-network

1. Enable `icc true` in daemon.json
```bash
cat /etc/docker/daemon.json
 
   {
     "icc" : true
   }
systemctl daemon-reload
systemctl restart docker
```

2. Start `dev-container1 and dev-container2`
```bash 
docker run -dit --name dev-container1 --network dev-network ubuntu
docker run -dit --name dev-container2 --network dev-network ubuntu
```

3. Login to `dev-container1`
```bash
# docker exec -ti dev-container1 bash
# apt get update 
# apt install iputils-ping
```

4. Test Connection with `dev-container2`
```bash
# ping -c 3 <ip address of dec-container2>
```

- Output:
```
PING dev-container2 (172.18.0.3): 56 data bytes

...


- Fail → containers can communicate via `dev-network`.

## Summary Table
| Container      | Network       | Can Ping             |
|----------------|---------------|--------------------|
| dev-container1 | dev-network   | dev-container2     |
| dev-container2 | dev-network   | dev-container1         |
| Host           | Not connected | Cannot ping by default |

## Summary Table After `icc` enable
| Container      | Network       | Will not Ping      |
|----------------|---------------|--------------------|
| dev-container1 | dev-network   | dev-container2     |
