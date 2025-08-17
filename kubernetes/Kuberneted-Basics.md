# Kubernetes Hands-on Scenarios – Pods, Services, Endpoints

---

## Scenario 1: Create a Pod
1. Create a pod running Nginx:
   ```bash
   kubectl run nginx-pod --image=nginx --restart=Never
````

2. Verify the pod is running:

   ```bash
   kubectl get pods
   ```

---

## Scenario 2: Dry Run & Generate Pod YAML

1. Generate the YAML definition of a pod without creating it:

   ```bash
   kubectl run nginx-pod --image=nginx --restart=Never --dry-run=client -o yaml > pod.yaml
   ```
2. Apply the YAML:

   ```bash
   kubectl apply -f pod.yaml
   ```
3. Verify:

   ```bash
   kubectl get pods
   ```

---

## Scenario 3: Expose Pod using ClusterIP Service

1. Expose the pod internally in the cluster:

   ```bash
   kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-clusterip
   ```
2. Check the service:

   ```bash
   kubectl get svc nginx-clusterip
   ```
3. Generate YAML (dry-run):

   ```bash
   kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-clusterip --type=ClusterIP --dry-run=client -o yaml > clusterip.yaml
   ```

---

## Scenario 4: Expose Pod using NodePort Service

1. Expose the pod on a NodePort:

   ```bash
   kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-nodeport --type=NodePort
   ```
2. Verify the NodePort:

   ```bash
   kubectl get svc nginx-nodeport
   ```
3. Access the service using:

   ```bash
   curl http://<NodeIP>:<NodePort>
   ```

---

## Scenario 5: Expose Pod using LoadBalancer Service

*(Works on cloud platforms like AWS, GCP, Azure)*

1. Expose the pod with a LoadBalancer:

   ```bash
   kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-lb --type=LoadBalancer
   ```
2. Check for external IP:

   ```bash
   kubectl get svc nginx-lb
   ```

---

## Scenario 6: Create Custom Endpoint & Service

1. Create an **endpoint.yaml**:

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
2. Create a **service.yaml**:

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-service
   spec:
     ports:
       - port: 80
   ```
3. Apply both:

   ```bash
   kubectl apply -f endpoint.yaml
   kubectl apply -f service.yaml
   ```
4. Verify:

   ```bash
   kubectl get endpoints my-service
   kubectl get svc my-service
   ```

---

By following these **scenarios step by step**, you’ll understand:

* How to create Pods
* How to expose them using Services (ClusterIP, NodePort, LoadBalancer)
* How to manually define Endpoints

```
