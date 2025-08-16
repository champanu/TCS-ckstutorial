#!/bin/bash
set -e

# Docker host IPs or DNS names for SANs
DOCKER_HOST="<host-private-ip>"
EXTRA_IP="<host-public-ip>"
EXTRA_DNS="<your-domain-name>"

# Output directory for certs
CERT_DIR="./docker-certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

echo "Generating CA private key and self-signed certificate..."
openssl genrsa -aes256 -passout pass:password -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -passin pass:password -sha256 -out ca.pem -subj "/CN=Docker-CA"

echo "Creating OpenSSL config for server cert with SANs..."
cat > server-openssl.cnf <<EOF
[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext
prompt             = no

[ req_distinguished_name ]
CN = $DOCKER_HOST

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = $DOCKER_HOST
IP.2 = $EXTRA_IP
DNS.1 = $EXTRA_DNS
EOF

echo "Generating server key and certificate signing request (CSR)..."
openssl genrsa -out server-key.pem 4096
openssl req -new -key server-key.pem -out server.csr -config server-openssl.cnf

echo "Signing server certificate with CA..."
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -passin pass:password \
  -CAcreateserial -out server-cert.pem -sha256 -extfile server-openssl.cnf -extensions req_ext

echo "Generating client key and certificate signing request (CSR)..."
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo "Signing client certificate with CA..."
openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem -passin pass:password \
  -CAcreateserial -out cert.pem -sha256

echo "Removing passphrase from client key for ease of use..."
openssl rsa -in key.pem -passin pass:password -out key.pem

echo "Cleanup CSR files and config..."
rm server.csr client.csr server-openssl.cnf

echo "Done. Certificates are in $CERT_DIR"
echo "Remember to copy ca.pem, cert.pem, and key.pem to your Docker client machine."
echo "Server cert now includes IPs: $DOCKER_HOST, $EXTRA_IP and DNS: $EXTRA_DNS"

