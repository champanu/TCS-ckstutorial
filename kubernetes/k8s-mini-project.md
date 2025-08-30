# K8s Mini Project: Frontend + MySQL (StatefulSet) with ConfigMap/Secret, Quotas, EFK Logging, Prometheus/Grafana

This mini project gives you a complete, reproducible setup to practice:

-   Frontend **Deployment** with ConfigMap-driven dynamic config
-   **MySQL StatefulSet** with PersistentVolumeClaims
-   **Secret** for DB password
-   **ResourceQuota** and **LimitRange** in a dedicated Namespace
-   Centralized logging to **EFK** (Elasticsearch + Fluent Bit + Kibana)
-   Pod scraping & dashboards via **Prometheus + Grafana**

You can paste each manifest below into files inside a folder (e.g.,
`k8s/`) and apply them in order.

> Tested on Kubernetes ≥1.25. Uses only commonly available features and
> standard Helm charts for stacks.

------------------------------------------------------------------------

## 1) Project Layout

    mini-project/
    ├─ README.md
    ├─ k8s/
    │  ├─ 00-namespace-quotas.yaml
    │  ├─ 01-secrets-configmaps.yaml
    │  ├─ 02-mysql-statefulset.yaml
    │  ├─ 03-frontend-deployment.yaml
    │  ├─ 04-prometheus-grafana-helm.md
    │  ├─ 05-efk-helm.md
    │  └─ 06-smoketest.md
    └─ app/
       └─ frontend/ (optional demo app)

... (truncated for brevity, but would include the whole text) ...
