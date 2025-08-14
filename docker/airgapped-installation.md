
## PORT MAPPING

```bash 
# docker run -p 8080:80 --name webserver -d -ti nginx
# docker container ls
# curl http://localhost:8080
```
### AUTO RESTART OF CONTAINER ON DAEMOn RESTART

```bash
# docker run -ti -d --restart=always ubuntu
# docker run -ti -d --restart=no ubuntu
# docker run -ti -d --restart=on-failure ubuntu
# docker run -ti -d --restart=unless-stopped ubuntu
```

### Pull Image From hub.docker.io or any registry

```bash
# docker login (by default hit to docker hub)

# docker login myprivaterepo.example.com (Provide username password)
```

### Will create file in home directory of user .docker/config.json

```bash
# docker pull nginx
# docker image (to verify)
```

### Build a Docker File
```bash 
# vim Dockerfile
FROM UBUNTU 
RUN apt update
RUN apt install telnet
EXPOSE 80

# docker build -t localimage:v1 .
```

### Build and Push Image to registry

```bash
# vim Dockerfile
FROM UBUNTU 
RUN apt update
RUN apt install telnet
EXPOSE 80

# docker build -t <org-name>/localimage:v1 .

# docker push <org-name>/localimage:v1
```

### Read Contant of a image without running as container

```bash 
# docker create --name tmp_container nginx:latest
# docker export tmp_container -o nginx.tar
# mkdir docker_fs
# tar -xf nginx.tar -C docker_fs
# cd docker_fs
```

### Read the Image layer history

```bash
# docker history nginx:latest
# docker info | grep -i "Storage Driver"
# cd /var/lib/volume/
```
#### You will See 3 Directories there
####  diff:- Contains the actual filesystem
####  link and lower files tells Docker how layer stack


### Build your own Private Docker Registry

```bash
# docker run -d -p 50001:5000 --name private-registry registry:2.7

# vim Dockerfile
FROM UBUNTU
RUN apt update
RUN apt install -y telnet
EXPOSE 80

# docker build -t localhost:5001/firstimage:v1 .
# docker push localhost:5001/firstimage:v1 
# docker rmi localhost:5001/firstimage:v1 (Delete local image)
# docker image
# docker pull localhost:5001/firstimage:v1
# docker image
```


## Install Docker in Airgapped Environmant

#### Download Latest Binary
```bash
# curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-28.3.3.tgz -o docker.tgz
# tar -xvzf docker.tgz
# mv docker/* /usr/local/bin/
```

#### Start Docker Daemon manually
```bash 
# dockerd --host=unix:///var/run/docker.sock
```

#### Create a service file
```bash
sudo tee /etc/systemd/system/docker.service <<'EOF'
[Unit]
Description=Docker Daemon
After=network.target

[Service]
ExecStart=/usr/local/bin/dockerd
Restart=always
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

# systemctl daemon-reload
# systemctl enable docker
# systemctl start docker
```

#### Deploy A container and Check
```bash

# docker version
# docker run -d -ti nginx
```

## Migration Docker volume from /var/lib/docker to /data/docker

```bash 
# mkdir -p /data/docker
# rsync -aP /var/lib/docker/ /data/docker/ (If previously path was /var/lib/docker)
# mkdir -p /etc/docker
# vim /etc/docker/daemon.json
{
  "data-root": "/data/docker"
}
# systemctl daemon-reload
# systemctl restart docker
# docker info | grep "Docker Root Dir"
# docker run -ti -d ubuntu
# ls -l
```

## Deploy image in Airgapped Machine

#### First Login to Machiine you have Internet and pull the image and save it as tar
```bash
# docker pull nginx:1.25
# docker save nginx:1.25 -o nginx.tar
```
#### Copy the tar file to Airgapped Machine and load the image
```bash
# docker load -i nginx.tar
# docker images
# docker run -ti -d nginx(pull it from local)
```


