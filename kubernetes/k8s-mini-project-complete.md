# Kubernetes Mini Project: Frontend + MySQL (StatefulSet) with ConfigMap/Secret, Quotas, EFK Logging, Prometheus/Grafana

This mini project provides a complete, reproducible setup to practice:

-   **Frontend Deployment** with ConfigMap-driven dynamic config
-   **MySQL StatefulSet** with PersistentVolumeClaims
-   **Secret** for DB password
-   **ResourceQuota** and **LimitRange** in a dedicated Namespace
-   Centralized logging to **EFK** (Elasticsearch + Fluent Bit + Kibana)
-   Pod scraping & dashboards via **Prometheus + Grafana**

You can paste each manifest below into files inside a folder (e.g.,
`k8s/`) and apply them in order.

------------------------------------------------------------------------

## 1) Namespace, ResourceQuota, and LimitRange

`00-namespace-quotas.yaml`

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mini-proj

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: mini-proj
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"

---
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-cpu-limits
  namespace: mini-proj
spec:
  limits:
    - default:
        cpu: 500m
        memory: 512Mi
      defaultRequest:
        cpu: 250m
        memory: 256Mi
      type: Container
```

------------------------------------------------------------------------

## 2) Secrets and ConfigMaps

`01-secrets-configmaps.yaml`

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: mini-proj
type: Opaque
stringData:
  mysql-root-password: mysecurepassword

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  namespace: mini-proj
data:
  APP_ENV: "production"
  API_ENDPOINT: "http://frontend.mini-proj.svc.cluster.local/api"
```

------------------------------------------------------------------------

## 3) MySQL StatefulSet with PVC

`02-mysql-statefulset.yaml`

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: mini-proj
spec:
  clusterIP: None
  ports:
    - port: 3306
      name: mysql
  selector:
    app: mysql

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: mini-proj
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          ports:
            - containerPort: 3306
              name: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: mysql-root-password
          volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
        - name: mysqld-exporter
          image: prom/mysqld-exporter
          ports:
            - containerPort: 9104
              name: metrics
  volumeClaimTemplates:
    - metadata:
        name: mysql-persistent-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

------------------------------------------------------------------------

## 4) Frontend Deployment

`03-frontend-deployment.yaml`

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: mini-proj
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: mini-proj
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: nginx:alpine
          ports:
            - containerPort: 80
          envFrom:
            - configMapRef:
                name: frontend-config
```

------------------------------------------------------------------------

## 5) Prometheus + Grafana (Helm)

Install Prometheus & Grafana via Helm:

``` bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create ns monitoring

helm install prometheus prometheus-community/kube-prometheus-stack   -n monitoring
```

Access Grafana:

``` bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
# login with admin/prom-operator
```

------------------------------------------------------------------------

## 6) EFK Logging

``` bash
helm repo add elastic https://helm.elastic.co
helm repo update

kubectl create ns logging

helm install elasticsearch elastic/elasticsearch -n logging
helm install kibana elastic/kibana -n logging
helm install fluent-bit fluent/fluent-bit -n logging   --set backend.type=es   --set backend.es.host=elasticsearch-master.logging.svc.cluster.local
```

Access Kibana:

``` bash
kubectl port-forward svc/kibana-kibana 5601:5601 -n logging
```

------------------------------------------------------------------------

## 7) Smoke Test

``` bash
kubectl get all -n mini-proj
kubectl logs deploy/frontend -n mini-proj
kubectl logs statefulset/mysql -n mini-proj
```

-   Verify Prometheus targets show both `frontend` and `mysql` pods.
-   Open Grafana → import dashboards for MySQL & Nginx.
-   Open Kibana → check logs from frontend and mysql pods.

------------------------------------------------------------------------

## 8) Cleanup

``` bash
kubectl delete ns mini-proj monitoring logging
```
