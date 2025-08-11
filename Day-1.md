## See Docker Version
```bash 
# docker version
```

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

## MANAGE CONTAINERS

```bash
#docker commit <container-id> newimage:latest (Create Image From Container)
```

```bash
#docker container inspect <container-id>

#docker nework inspect <network-name>
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

## COPY TO/FROM CONTAINER

```bash
# echo "COPY FILE TO CONTAINER" > file1.txt
# docker cp file1.txt <container-id>:/tmp
# docker exec <container-id> cat /tmp/file1.txt
```
