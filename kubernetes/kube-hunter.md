kube-hunter: Kubernetes Security Assessment

**kube-hunter** is a tool from Aqua Security used to **hunt for security weaknesses in Kubernetes clusters**.  
It can be run in two modes:
- **Passive Mode** → run inside a cluster to collect information safely.
- **Active/Hunting Mode** → attempts to exploit vulnerabilities (for testing).

---
Via Docker Container
```bash
docker run -it aquasec/kube-hunter --remote <CLUSTER-IP>
```



Inside Cluster

```bash
# kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-hunter/main/job.yaml

# kubectl get jobs

#kubectl logs job/kube-hunter
```
