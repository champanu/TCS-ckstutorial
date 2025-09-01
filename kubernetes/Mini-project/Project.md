Awesome brief! I put a full mini-project in the canvas with:

* Namespace + ResourceQuota + LimitRange
* Secret (MySQL password) & ConfigMap (to “push” frontend changes)
* MySQL StatefulSet with PVC + mysqld-exporter sidecar
* Frontend Deployment wired to auto-rollout on ConfigMap changes
* Helm steps for Prometheus/Grafana (metrics & dashboards)
* Helm steps for EFK (Fluent Bit + Elasticsearch + Kibana)
* Smoketests and cleanup

You can copy the manifests into a repo as-is and `kubectl apply` them in order. If you want, I can also turn this into a single Helm chart or Kustomize overlay—just say the word.

