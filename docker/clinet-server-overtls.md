<img width="1840" height="996" alt="image" src="https://github.com/user-attachments/assets/fbc410a0-fac8-4c20-bd12-c2638827744e" />


<img width="2514" height="992" alt="image" src="https://github.com/user-attachments/assets/e496c8b1-f37b-4d97-891b-7191847cf695" />

add below entrt in docker.srv

Exestart = /usr/bin/dockerd -H unix://var/run/docker.sock -H tcp://0.0.0.0:2376 in docker.service

systemctl daemon-reoad
system restart docker
netstat -pant | grep 2376 (on host server)


On Client 
apt update
apt install docker-cli
export DOCKER_HOST=tcp://<HOST-SERVER-IP>:2376
docker info
Install a container from clienr

docker container -rid --name client:container ununtu


# SECURE
On Docker Host 

Create sertificate
./createcert.sh 
ls -l docker.cert (to verfy the certificate)

```bash
cat /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --tlsverify \
  --tlscacert=/home/ubuntu/docker-certs/ca.pem \
  --tlscert=/home/ubuntu/docker-certs/server-cert.pem \
  --tlskey=/home/ubuntu/docker-certs/server-key.pem \
  -H tcp://0.0.0.0:2376 \
  -H unix:///var/run/docker.sock

```
daemon reload
docker restart
netstat -pant | grep 2376


On Clinet
On Client 
apt update
apt install docker-cli
mkdir -p /opt/docker_cert
copy the ca.pem cert.pem and cert.key form Docker Server to /opt/docker_cert
export DOCKER_HOST=tcp://<HOST-SERVER-IP>:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/opt/docker_cert
docker info
Install a container from clienr


Teste:

unset DOCKER_TLS_VERIFY
unset DOCKER_CERT_PATH

docker info : fail


export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/opt/docker_cert
docker info will able to connect
