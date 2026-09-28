# NFS Client Configuration

## Ubuntu

Install the NFS client package:

```bash
sudo apt update
sudo apt install nfs-common -y
```

Discover exports:

```bash
showmount -e 192.168.20.181
```

Create mount point:

```bash
sudo mkdir -p /data/prod/ubuntu-workload
```

Mount:

```bash
sudo mount -t nfs \
192.168.20.181:/mnt/storage_tank/production \
/data/prod/ubuntu-workload
```

---

## CentOS

Install NFS utilities:

```bash
sudo dnf install nfs-utils -y
```

Discover exports:

```bash
showmount -e 192.168.20.181
```

Create mount point:

```bash
sudo mkdir -p /files/prod/centos-admin
```

Mount:

```bash
sudo mount -t nfs \
192.168.20.181:/mnt/storage_tank/production \
/files/prod/centos-admin
```

---

## Verify

```bash
df -h
```

or:

```bash
mount | grep -i production
```

or:

```bash
findmnt /files/prod/centos-admin
```

---

## Read/Write Validation

Create a file:

```bash
sudo touch /files/prod/centos-admin/centos-test.txt
```

Write data:

```bash
sudo uname -a | sudo tee \
/files/prod/centos-admin/aboutMyCentOSWorkload.txt
```

Read:

```bash
cat /files/prod/centos-admin/aboutMyCentOSWorkload.txt
```

---

## Cross-Client Validation

Because both Linux systems consume the same centralized NFS storage, a file created from one client can be observed from another client according to the configured permissions.

This validates:

```text
CentOS
   ↕
TrueNAS NFS
   ↕
Ubuntu
```
