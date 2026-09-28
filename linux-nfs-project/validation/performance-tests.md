# NFS Performance Testing

## Tool

The project uses `fio` to benchmark the NFS-mounted storage.

Packages:

### Ubuntu

```bash
sudo apt install fio sysstat nfs-common -y
```

### CentOS

```bash
sudo dnf install fio sysstat nfs-utils -y
```

---

# Sequential Read

```bash
fio --name=nfs-sequential-read \
  --directory=/files/prod/griffindor/ \
  --size=1G \
  --rw=read \
  --bs=1M \
  --direct=1 \
  --iodepth=16 \
  --runtime=60 \
  --time_based
```

### Recorded Result

```text
Bandwidth: 218 MiB/s
IOPS:      218
Runtime:   60 seconds
```

---

# Sequential Write

```bash
fio --name=nfs-sequential-write \
  --directory=/files/prod/griffindor/ \
  --size=1G \
  --rw=write \
  --bs=1M \
  --direct=1 \
  --iodepth=16 \
  --runtime=60 \
  --time_based
```

### Recorded Result

```text
Bandwidth: 128 MiB/s
IOPS:      127
Runtime:   60 seconds
```

---

# Result Interpretation

| Test             | Bandwidth | IOPS |
| ---------------- | --------: | ---: |
| Sequential Read  | 218 MiB/s |  218 |
| Sequential Write | 128 MiB/s |  127 |

The observed read throughput was higher than write throughput in this lab.

These measurements should not be interpreted as production hardware capability.

They represent this specific virtualized environment and workload.

---

# Monitoring During Testing

Use:

```bash
iostat -xz 2 5
```

```bash
nfsstat -m
```

```bash
nfsstat -c
```

```bash
ip -s link
```

```bash
ss -tan
```

---

# Engineering Consideration

Network storage performance is affected by more than the storage disks.

The complete path is:

```text
Application
 ↓
Filesystem
 ↓
NFS Client
 ↓
Virtual Network
 ↓
NFS Server
 ↓
ZFS
 ↓
Virtual Disk
 ↓
Physical Storage
```

Therefore performance results must always be interpreted in context.
