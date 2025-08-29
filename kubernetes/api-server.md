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
