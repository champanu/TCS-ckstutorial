# Scenario: Docker Volume Usage

## Goal

- Demonstrate how Docker volumes work for persistent storage.
- Show difference between **named volumes** and **bind mounts**.
- Verify that data persists even if containers are removed.

---

## Step 1: Create a Named Volume

```bash
docker volume create mydata
```

---

## Step 2: Use the Named Volume in a Container

```bash
# Start a container with the volume mounted to /data
docker run -dit --name vol_container --mount source=mydata,target=/data alpine sh

# Add a file inside the container
docker exec vol_container sh -c "echo 'Hello from volume' > /data/hello.txt"
```

---

## Step 3: Remove the Container and Reuse the Volume

```bash
docker rm -f vol_container

# Start a new container with the same volume
docker run -it --rm --mount source=mydata,target=/data alpine sh

# Inside container
cat /data/hello.txt
```

✅ **Result:** The file still exists because it is stored in the volume, not in the container's writable layer.

---

## Step 4: Bind Mount Example

```bash
# Use a local folder as storage
mkdir ~/hostdata

docker run -dit --name bind_container \
  --mount type=bind,source=$HOME/hostdata,target=/app alpine sh

# Add a file from host
echo "From Host" > ~/hostdata/hostfile.txt

# Verify inside container
docker exec bind_container cat /app/hostfile.txt
```

✅ **Result:** Files are shared between host and container in real-time.

---

## Summary Table

| Type         | Location                       | Use Case                               |
| ------------ | ------------------------------ | --------------------------------------- |
| Named Volume | Managed by Docker in /var/lib  | Persistent container data               |
| Bind Mount   | Host filesystem path           | Direct file sharing between host & app  |

