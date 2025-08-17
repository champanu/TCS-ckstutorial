
<img width="2148" height="1090" alt="image" src="https://github.com/user-attachments/assets/5008248e-4c62-4798-8dde-18cc84f31feb" />

## See Docker Version
```bash 
# docker version

# docker info 
```

# RUN DOCKER COMMANDS 

## Docker Run Commands
```bash
# docker container run nginx

# docker container ls (to see all the running container) 

# docker container ls -a  (to see all the container using paused container)
```

```bash
# docker container run ubuntu sleep 30

# docker container ls 
```


```bash
# docker container run -d nginx ( -d to run container in detached mode)

# docker container rum --rm ubuntu ( --rm instruct Docker to autometically remove container when it exits)
```

```bash
# docker container -ti nginx ( -ti Attach your linux terminal to container )
```

```bash
# docker container ls
# docker container attach <container-id>
(You are inside the container.To come out of container dont type exit. Use CTRL+P CTRL+Q)
```

```bash
# docker container run --name firstcontainer nginx ( Assign name to a container)
# docker container ls 
```

```bash
# docker container run --hostname dev-host nginx (Assign hostname to container)
# docker container ls
# docker container attach <container-id>
# hostname
```

# MANAGE CONTAINERS

```bash
#docker commit <container-id> newimage:latest (Create Image From Container)
```

```bash
#docker container inspect <container-id>

#docker nework inspect <network-name>

#docker volume inspect <volume-name>
```

```bash
#docker kill <container-id> (To kill Container)

#docker stop <container-id>

#docker start <container-id>

#docker pause <container-id>

#docker unpause <container-id>

```

```bash
#docker rename <container-id> new-name
```

```bash
# docker rm <container-id> (To remove container from host storage)
```  

# COPY TO/FROM CONTAINER

```bash
# echo "COPY FILE TO CONTAINER" > file1.txt
# docker cp file1.txt <container-id>:/tmp
# docker exec <container-id> cat /tmp/file1.txt


# docker container ls
# docker attach <container-id> 
# echo "COPY FILE FROM CONTAINER" > /tmp/file2.txt
# CTRL+P CTRL+Q (to come out from container)
# docker cp <container-id>:/tmp/file2.txt /tmp/file2.txt
# cat /tmp/file2.txt
```

# EXECUTE COMMAND IN CONTAINER
```bash 
# docker exec <container-id> ls
# docker exec -ti <container-id> ls
```

# ACCESS CONTAINER LOGS
```bash
# docker logs <container-id>
# docker logs <container-id> --follow (To See continuous logs)
# docker logs <container-id> -n 5 (last 5 line of log)
```

# VIEW CONTAINER RESOURCES UTILISATION
```bash
# docker stats <container-id>
# docker stats (For all Containers)
```

# Docker Networking

### TYPES: Bridge(Default), None, Host

```bash
# docker network ls
```

```bash
# docker network create --driver bridge --subnet 192.168.100.0/24 --gateway 192.168.100.1 dev-network

# docker network create --drever bridge --subnet 192.168.200.0/24 --gateway 192.168.200.1 qa-network

```
### Attach Container name dev-container to dev-network and qa-container to qa-network
```bash
# docker container run --network dev-network -d -ti --name dev-container1 ubuntu
# docker container run --network dev-network -d -ti --name dev-container2 ubuntu

# docker container run --network qa-network -d -ti --name qa-container1 ubuntu
# docker container run --network dev-network -d -ti --name qa-container2 ubuntu
```

### Inspect the Containers
```bash
# docker container inspect <dev-container-id>

# docker container inspect <qa-container-id>
```

### Connetion Test within Bridge network 
```bash
# docker attach <dev-container1>
# apt install iputils-ping
# ping <ip-address of dev-container2> (it should ping)
# ping <ip-address of qa-container1> (will not ping as in different network)
```
```bash
# docker attach <qa-container1>
# apt install iputils-ping
# ping <ip-address of qa-container2> (it should ping)
# ping <ip-address of dev-container1> (will not ping as in different network)
```

### Attach No IP To Container
```bash 
# docker container run --network none -d -ti --name none-container ubuntu

# docker container inspect <container-id>
```

### Attach Host Network to Container
```
# docker container run --network host -d -ti --name host-container ubuntu

# docker container inspect < host-cobtainer-id>   
```
