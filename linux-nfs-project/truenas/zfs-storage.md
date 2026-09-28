# ZFS Storage Design

## Storage Pool

The project uses a ZFS pool named:

```text
storage_tank
```

The pool is divided into dedicated datasets according to workload and access requirements.

---

## Dataset Structure

```text
storage_tank
│
├── production
│
├── nfs-lab
│   ├── shared
│   ├── griffindor
│   ├── slytherin
│   └── restricted
│
└── backup
```

---

## Production Storage

The production dataset is backed by two 40 GB virtual disks using a mirrored layout.

```text
Disk 1 ─────┐
             ├── Mirror
Disk 2 ─────┘
```

The objective is to provide redundancy within the storage pool.

---

## Why Dedicated Datasets?

The project deliberately avoids creating NFS shares directly against the pool root.

Instead:

```text
ZFS Pool
   ↓
Dataset
   ↓
NFS Share
```

Example:

```text
storage_tank
└── production
```

NFS path:

```text
/mnt/storage_tank/production
```

This provides a clean boundary for:

* permissions
* snapshots
* quotas
* share configuration
* workload separation

---

## Dataset vs ZVOL

### Dataset

A dataset is a ZFS filesystem intended for file-based storage.

Typical uses:

```text
NFS
SMB
Linux files
Application data
Backups
Documents
```

### ZVOL

A ZVOL is a ZFS block device.

Typical use:

```text
ZFS
 ↓
ZVOL
 ↓
Block device
 ↓
VM / iSCSI / operating-system filesystem
```

The project therefore uses datasets for the NFS file-storage workload.

---

## Redundancy

The production pool uses mirrored virtual disks.

The project also expanded the storage environment with additional disks and separate datasets for lab scenarios.

---

## Storage Validation

Useful commands from the TrueNAS shell include:

```bash
zpool status
zpool list
zfs list
```

Snapshot visibility can be checked using:

```bash
zfs list -t snapshot
```

---

## Engineering Principle

Storage design should be driven by workload requirements.

Do not treat:

```text
Pool
Dataset
ZVOL
NFS Share
```

as interchangeable objects.

Each provides a different abstraction and operational purpose.
