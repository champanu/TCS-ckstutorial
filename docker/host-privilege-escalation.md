<img width="2518" height="1320" alt="image" src="https://github.com/user-attachments/assets/9987db74-add8-443f-b29e-eaad1d8285b2" />



# Host Machine Privilege Escalation Attempt


## Unsave Container Mounting docker.sock in container  
```bash
docker run -it --rm --privileged -v /:/mnt ubuntu:24.04 bash
ls /mnt
cat /mnt/etc/passwd

chroot /mnt /bin/bash (You’re now effectively in the host filesystem as root)

Docker socket escape

docker run -it -v /var/run/docker.sock:/var/run/docker.sock docker:24.0.5 sh
docker ps (inside container we can run)
docker run -it --rm --privileged ubuntu:24.04 bash (Launh Container)
```
### Output:  Hacker Can Run Docker Commands from inside the container

## Goal
Demonstrate how a normal user could try to gain root access on a Linux host, and how `no-new-privileges` can prevent it.

---

## Step 1: Create a Normal User
```bash
sudo useradd -ms /bin/bash testuser
sudo passwd testuser
su - testuser
```
- `testuser` is a normal user.  
- Normal users should **not be able to perform root-only tasks**.

---

## Step 2: Try a Root-Only Command
```bash
ls /root
```
- Output:
```
ls: cannot open directory '/root': Permission denied
```
- Result: Normal user cannot access root files 

---

## Step 3: Simulate a Vulnerable Program
Some programs have **SUID permission**, which can let normal users become root.

```bash
sudo cp /bin/bash /tmp/bash-root
sudo chmod +s /tmp/bash-root
```
- `/tmp/bash-root` can now run **as root** if executed.

---

## Step 4: Test Privilege Escalation
As `testuser`:
```bash
/tmp/bash-root -c "whoami"
```
- Output: `root` → dangerous!  
- Explanation: Any normal user could now become root.

---

## Step 5: Protect with `no-new-privileges`
`no-new-privileges` prevents processes from gaining extra privileges.

1. Run a new bash shell with protection:
```bash
sudo unshare --pid --fork --mount-proc bash
prctl --no-new-privs
```

2. Test the same SUID binary:
```bash
/tmp/bash-root -c "whoami"
```
- Output: `testuser` → cannot become root 


---

## Step 6: Explanation
- **Without `no-new-privileges`:** Vulnerable programs can give users root → host at risk.  
- **With `no-new-privileges`:** Users cannot gain extra privileges → host is safer.

---



## Summary Table

| Scenario                     | Result Without Protection | Result With `no-new-privileges` |
|-------------------------------|--------------------------|--------------------------------|
| Normal user runs root command | Fails                    | Fails                          |
| User runs SUID binary         | Succeeds → becomes root  | Fails                          |
| Risk                          | High                     | Low                            |
