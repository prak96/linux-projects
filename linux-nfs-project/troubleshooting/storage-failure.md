# Storage Failure Troubleshooting

> Storage troubleshooting covering VMware Workstation VM disks, TrueNAS storage and Linux/NFS clients.

## 1. Storage Troubleshooting Model

Storage failures should be isolated layer by layer:

```text
Virtual Disk
    ↓
Guest OS detects disk
    ↓
TrueNAS detects disk
    ↓
ZFS pool
    ↓
Dataset / ZVOL
    ↓
NFS export
    ↓
Linux mount
    ↓
Filesystem access
```

---

# 2. Failure: Newly Added TrueNAS Data Disks Not Visible

## Symptom

Additional virtual data disks were added to the TrueNAS VM through VMware Workstation, but they were initially not visible in the TrueNAS management interface.

## Troubleshooting

First verify that the VM has the expected virtual disks.

At the TrueNAS console, inspect available storage devices.

If the virtual disks were added after the VM was already running, perform a controlled reboot/rescan as appropriate.

In this lab, restarting the TrueNAS VM caused the newly attached disks to become visible.

## Validation

Confirm the disks are visible before creating:

```text
ZFS pool
Dataset
ZVOL
```

---

# 3. Do Not Confuse Dataset and ZVOL

### Dataset

Used primarily for filesystem-oriented storage:

```text
tank
└── production
    ├── files
    ├── backups
    └── application-data
```

Typical use:

* NFS
* SMB
* Linux file storage
* Backups
* Application data

### ZVOL

A block device presented from ZFS:

```text
tank
└── vm-disk-01
```

Typical use:

* Virtual disks
* iSCSI
* Block storage

The distinction matters during storage design and troubleshooting.

---

# 4. Verify Storage Capacity

Linux:

```bash
df -h
```

For filesystem/inode usage:

```bash
df -ih
```

For block devices:

```bash
lsblk
```

For mounted filesystems:

```bash
findmnt
```

---

# 5. Storage Network vs Storage Device

A common troubleshooting mistake is treating every storage problem as a disk problem.

The NFS workload uses:

```text
VMnet20
192.168.20.0/24
```

Therefore:

```text
Storage connectivity
```

and:

```text
Storage capacity
```

must be diagnosed separately.

Example:

```text
NFS unreachable
```

does not necessarily mean:

```text
Disk unavailable
```

It may be:

```text
NIC
IP
Routing
NFS service
Export authorization
```

---

# 6. Performance Investigation

When storage appears slow, do not immediately conclude that the storage device is overloaded.

Collect evidence.

```bash
iostat -xz 2 5
```

Network:

```bash
ip -s link
```

NFS mount information:

```bash
nfsstat -m
```

Filesystem:

```bash
df -h
```

---

# 7. Storage Failure Decision Tree

```text
Storage workload failing
        |
        v
Can Linux see the mount?
      /        \
    NO          YES
    |            |
Check NFS     File operation
connectivity   failing?
                  |
                  v
             Check permissions
                  |
                  v
             Performance issue?
                  |
                  v
        Check I/O + network metrics
```

---

# 8. Evidence Collection

### Block devices

```bash
lsblk
```

### Filesystems

```bash
df -hT
```

### Mounts

```bash
findmnt
```

### I/O

```bash
iostat -xz 2 5
```

### Network

```bash
ip -s link
```

### NFS

```bash
nfsstat -m
```

---

# 9. Engineering Lesson

Storage troubleshooting should distinguish between:

```text
Compute
Network
Storage device
Filesystem
NFS service
Permissions
Performance
```

A storage workload can fail even when the underlying disks are healthy.

Likewise, healthy disks do not guarantee healthy storage access.

The objective is therefore to identify the exact failing layer before changing the configuration.
