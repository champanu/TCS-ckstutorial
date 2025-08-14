# Docker Volume Scenarios

## Scenario 1 – Host Path Mount
**Goal:** Share a folder from host to container.
```bash
# On Docker host
mkdir /data1
docker run -v /data1:/data -d -ti --name host-path-container ubuntu

# Inside container
docker attach host-path-container
cd /data
touch file.txt
# Detach without stopping container
CTRL+P CTRL+Q

# Back on host – verify
ls /data1
```
**Outcome:** Files created in container are visible on host.

---

## Scenario 2 – Named Volume
**Goal:** Persist data independent of container lifecycle.
```bash
docker volume create my-volume
docker run -v my-volume:/data -d -ti --name volume-container ubuntu

# Inside container
docker attach volume-container
cd /data
touch file1.txt
CTRL+P CTRL+Q

# On host
ls /var/lib/docker/volumes/my-volume/_data/
```
**Outcome:** Volume data stays even after container removal.

---

## Scenario 3 – NFS Volume
**Goal:** Use remote NFS share with Docker.
```bash
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=<nfs-server-ip>,rw,nfsvers=4 \
  --opt device=:/nfvolume \
  nfs-volume

docker run -v nfs-volume:/data -d -ti --name nfs-container ubuntu

# Inside container
docker attach nfs-container
cd /data
touch file3.txt
```
**Outcome:** File is visible in the remote NFS share.

---

## Scenario 4 – S3 Bucket Mount (s3fs)
**Goal:** Map an S3 bucket to a container path.
```bash
apt install s3fs
echo "<AWS_ACCESS_KEY>:<AWS_SECRET>" > ~/.passwd-s3fs
chmod 600 ~/.passwd-s3fs
mkdir /mnt/mybucket
s3fs <bucket-name> /mnt/mybucket -o passwd_file=~/.passwd-s3fs -o allow_other

docker run -v /mnt/mybucket:/tmp -d -ti ubuntu
docker attach <container-id>
cd /tmp
touch file4.txt
```
**Outcome:** File shows up in your S3 bucket.

---

## Scenario 5 – Volume Quota with XFS
**Goal:** Limit space a container can use.
```bash
pvcreate /dev/xvdg
vgcreate vg1 /dev/xvdg
lvcreate -L +1G -n lv1 vg1
mkfs.xfs /dev/mapper/vg1-lv1

mkdir -p /mnt/mydata
mount -o pquota /dev/mapper/vg1-lv1 /mnt/mydata
echo "100:/mnt/mydata" | sudo tee -a /etc/projects
echo "myproj:100" | sudo tee -a /etc/projid
xfs_quota -x -c 'limit -p bsoft=500m bhard=500m myproj' /mnt/mydata
xfs_quota -x -c "report -p" /mnt/mydata

docker run -it --rm -v /mnt/mydata:/data ubuntu bash
cd /data
dd if=/dev/zero of=file600MB bs=1M count=600
```
**Outcome:** File creation fails when exceeding quota.

---

## Scenario 6 – Migrating Docker Data Root
**Goal:** Move `/var/lib/docker` to `/data/docker`.
```bash
mkdir -p /data/docker
rsync -aP /var/lib/docker/ /data/docker/

mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "data-root": "/data/docker"
}
EOF

systemctl daemon-reload
systemctl restart docker
docker info | grep "Docker Root Dir"
```
**Outcome:** Docker now uses new storage location.

