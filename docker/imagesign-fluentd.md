## Fluentd Lof Forwarder

<img width="2882" height="1390" alt="image" src="https://github.com/user-attachments/assets/3781acfb-067c-4495-81bd-163608b5aad4" />



## Image Sighining And Validation

<img width="2330" height="1318" alt="image" src="https://github.com/user-attachments/assets/543de4a8-63b1-46bc-bd38-cabb012e7e9c" />


## Install Cosign
```bash
# COSIGN_VERSION="v2.1.1"
# wget https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64

# chmod +x cosign-linux-amd64

# mv cosign-linux-amd64 /usr/local/bin/cosign

# cosign version
```

## Install crane
```bash
# apt install snap

# snap install go --clasic

# go install github.com/google/go-containerregistry/cmd/crane@latest

# export PATH=$PATH:$HOME/go/bin
```

## Docker File Linter
```bash
# For Linux AMD64
# wget -O hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
# chmod +x hadolint
# sudo mv hadolint /usr/local/bin/
# hadolint --version
# hadolint Dockerfile
```

## Install Fluentd
```bash
# curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-jammy-fluent-package5.sh | sh

# /opt/fluent/bin/fluent-gem install fluent-plugin-s3 (Install Support for Plugin)

# /opt/fluent/bin/fluent-gem list | grep s3

# cat /etc/docker/daemon.json 
{
  "log-driver": "fluentd",
  "log-opts": {
    "fluentd-address": "127.0.0.1:24224",
    "tag": "docker.{{.Name}}"
  }
}

# systemctl restart docker

# netstat -pant | grep 24224

# cat /etc/fluent/fluentd.conf 
## 1. Input: Accept logs from Docker via Fluentd logging driver
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

## 2. Output: Store logs in Amazon S3
<match **>
  @type s3

  # AWS credentials (replace with your real keys)
  aws_key_id       xxxxxxxxxxxx
  aws_sec_key      yyyyyyyyyyyyyy

  # S3 bucket settings
  s3_bucket        <your-bucket-name>
  s3_region        us-east-1
  path             docker/
  store_as         gzip

  # Buffer settings: Flush every 1 minute
  <buffer time>
    @type file
    path /tmp/fluent/s3
    timekey 1m            # rotate files every 1 minute
    timekey_wait 30s      # wait 30s for late logs
    timekey_use_utc true
    flush_mode immediate
    chunk_limit_size 5m
    queue_limit_length 128
  </buffer>
</match>

# systemctl restart fluentd

# docker info | grep "Logging Driver"

# docker run --rm busybox sh -c 'while true; do echo "Hello from busybox $(date)"; sleep 2; done'
```
