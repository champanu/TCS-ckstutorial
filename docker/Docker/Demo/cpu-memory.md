<img width="2102" height="752" alt="image" src="https://github.com/user-attachments/assets/3f3ef4b8-0160-47ed-b179-d2a1cf2364aa" />


# Docker CPU & Memory Management – Guide with Scenarios

## 1. Introduction

By default, Docker containers **share the host’s CPU and memory** without hard limits.  
You can control this using the **cgroup** options:

- **CPU** → Control scheduling time (shares, quota, period, cpuset).
- **Memory** → Limit max usage and set swap behavior.

---

## 2. CPU Management

### CPU Sharing (Relative Weight)
```bash
docker run -d --name app1 --cpu-shares=1024 busybox sh -c "while true; do :; done"
docker run -d --name app2 --cpu-shares=512  busybox sh -c "while true; do :; done"
````

* **Meaning**: `app1` gets twice as much CPU as `app2` when competing.
* **No limit** when CPU is idle — shares only matter under contention.

**Monitor Usage:**

```bash
docker stats
```

---

### Dedicated CPU (Pinning)

```bash
docker run -d --cpuset-cpus="0" busybox sh -c "while true; do :; done"
docker run -d --cpuset-cpus="1" busybox sh -c "while true; do :; done"
```

* **Meaning**: Each container runs only on the assigned CPU core(s).
* Ensures predictable performance for CPU-bound workloads.

---

### CPU Quota (Absolute Limit)

```bash
docker run -d --cpus="0.5" busybox sh -c "while true; do :; done"
```

* Limits container to **50% of a single CPU core**.

---

## 3. Memory Management

### Hard Memory Limit

```bash
docker run -d --memory="256m" busybox sh -c "tail -f /dev/null"
```

* Container is **killed** if it exceeds the memory limit.

---

### Memory + Swap

```bash
docker run -d --memory="256m" --memory-swap="512m" busybox sh -c "tail -f /dev/null"
```

* 256 MB RAM + 256 MB swap allowed.

---

### Disable Swap

```bash
docker run -d --memory="256m" --memory-swap="256m" busybox sh -c "tail -f /dev/null"
```

* Swap disabled (swap value = memory limit).

---

## 4. Scenarios

### Scenario 1 – CPU Share Priority

1. Run containers with different shares:

   ```bash
   docker run -d --cpu-shares=1024 prog1
   docker run -d --cpu-shares=256  prog2
   ```
2. Stress both containers.
3. Under load, `prog1` gets **4x CPU time** vs `prog2`.

---

### Scenario 2 – Dedicated Core for Predictable Latency

1. Assign cores:

   ```bash
   docker run -d --cpuset-cpus="0" low_latency_app
   docker run -d --cpuset-cpus="1,2" batch_job
   ```
2. Prevents noisy-neighbor CPU stealing.

---

### Scenario 3 – Memory Limit to Prevent Host OOM

1. Start container with a small memory limit:

   ```bash
   docker run -d --memory="100m" mem_hog_app
   ```
2. Inside container:

   ```bash
   stress --vm 1 --vm-bytes 200M --vm-hang 0
   ```
3. Container is **killed** when limit exceeded, host unaffected.

---

### Scenario 4 – Memory + Swap for Controlled Degradation

1. Allow small swap:

   ```bash
   docker run -d --memory="256m" --memory-swap="512m" swap_app
   ```
2. Under load, app slows down but doesn’t crash — useful for non-critical tasks.

---

## 5. Best Practices

* For **shared environments**, use `--cpu-shares` and `--memory` to prevent noisy neighbors.
* For **dedicated workloads**, use `--cpuset-cpus` and absolute limits (`--cpus`, `--memory`).
* Always test workloads with `docker stats` to verify settings.
* Avoid setting limits **too tight** — may cause instability.
* Combine CPU/memory limits with capability dropping for full resource & privilege control.
