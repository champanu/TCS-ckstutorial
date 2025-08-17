# Kubernetes Basics – Pods, Services, Endpoints

## 1. Create a Pod
```bash
kubectl run nginx-pod --image=nginx --restart=Never
````

Verify:

```bash
kubectl get pods
```

---

## 2. Dry Run & Generate YAML

Create a Pod YAML without actually deploying:

```bash
kubectl run nginx-pod --image=nginx --restart=Never --dry-run=client -o yaml > pod.yaml
```

Apply the YAML:

```bash
kubectl apply -f pod.yaml
```

---

## 3. Create a ClusterIP Service

ClusterIP is the default service type (accessible only inside the cluster).

```bash
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-clusterip
```

Dry run YAML:

```bash
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-clusterip --type=ClusterIP --dry-run=client -o yaml > clusterip.yaml
```

---

## 4. Create a NodePort Service

Exposes the service on each node’s IP at a static port.

```bash
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-nodeport --type=NodePort
```

Dry run YAML:

```bash
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-nodeport --type=NodePort --dry-run=client -o yaml > nodeport.yaml
```

Check NodePort:

```bash
kubectl get svc nginx-nodeport
```

---

## 5. Create a LoadBalancer Service

Used in cloud environments (AWS, GCP, Azure).

```bash
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-lb --type=LoadBalancer
```

Dry run YAML:

```bash
kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-lb --type=LoadBalancer --dry-run=client -o yaml > loadbalancer.yaml
```

---

## 6. Create an Endpoint

Manually map an external service into Kubernetes.

**endpoint.yaml**

```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 10.0.0.25
    ports:
      - port: 80
```

**service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - port: 80
```

Apply:

```bash
kubectl apply -f endpoint.yaml
kubectl apply -f service.yaml
```

---

With these commands you can:

* Deploy Pods
* Generate YAML manifests
* Expose services (ClusterIP / NodePort / LoadBalancer)
* Create custom Endpoints

```
