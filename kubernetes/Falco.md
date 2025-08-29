Here’s your guide converted into **Markdown (.md) format** with headings, steps, and code blocks:

````markdown
# Falco Setup with Slack Integration and Custom Rules

This guide demonstrates how to install and configure **Falco** on Kubernetes worker nodes, integrate it with **Slack**, and add **custom rules**.

---

## Step 1: Label Worker Nodes

```bash
kubectl label node kworker1.kubeopscloud.uk node-role=worker
kubectl label node kworker2.kubeopscloud.uk node-role=worker
````

---

## Step 2: Install Falco on Worker Nodes

```bash
helm install falco falcosecurity/falco \
  --create-namespace \
  --namespace falco \
  --version 4.0.0 \
  --set tty=true \
  --set nodeSelector."node-role"=worker
```

Verify installation:

```bash
kubectl get pods -n falco -o wide
```

---

## Step 3: Test Falco Detection

Run a test pod and perform sensitive actions:

```bash
kubectl run --rm -it test --image=alpine -- sh

cat /etc/passwd
cat /etc/group
exit
```

Check Falco logs:

```bash
kubectl logs -n falco -l app.kubernetes.io/name=falco | grep Warning
```

---

## Step 4: Integrate Falco with Slack

Add and update Falco Helm repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

Upgrade Falco with Slack integration:

```bash
helm upgrade falco falcosecurity/falco -n falco \
  --set falcosidekick.enabled=true \
  --set falcosidekick.config.slack.webhookurl="https://hooks.slack.com/services/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" \
  --set nodeSelector.node-role=worker
```

### Test Slack Alerts

Login into a pod and perform sensitive file reads:

```bash
kubectl run --rm -it test --image=alpine -- sh

cat /etc/passwd
cat /etc/group
exit
```

You should see alerts in **Slack**.

---

## Step 5: Add Custom Rules

```bash
helm upgrade falco falcosecurity/falco -n falco \
  --set falcosidekick.enabled=true \
  --set-file customRules.rules=falco-best-practice-rules.yaml
```

---

## Step 6: Expose Falco Over UI

```bash
helm upgrade falco falcosecurity/falco -n falco \
  --set falcosidekick.enabled=true \
  --set falcosidekick.config.slack.webhookurl="https://hooks.slack.com/services/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" \
  --set nodeSelector.node-role=worker \
  --set falcosidekick.ui.enabled=true
```

---

## Summary

Installed **Falco** on worker nodes
Tested detection by reading `/etc/passwd` and `/etc/group`
Integrated alerts with **Slack**
Added **custom Falco rules**
Exposed **Falco UI** for monitoring

```


