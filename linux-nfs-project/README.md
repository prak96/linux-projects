# Linux + TrueNAS NFS Storage Infrastructure Lab

Production-style Linux storage infrastructure lab built with **TrueNAS, ZFS, NFS, CentOS and Ubuntu**.

The objective of this project was to simulate the operational lifecycle of centralized Linux storage — from storage provisioning and NFS deployment to access control, persistent mounts, failure simulation, performance validation, monitoring, and recovery.

Rather than only deploying an NFS share, this lab focuses on **real operational problems and their resolution**.

---

## Project Overview

This lab implements a centralized TrueNAS storage platform consumed by independent Linux client/workload servers.

```text
                    ┌──────────────────────────┐
                    │      VMware Workstation   │
                    │                          │
                    │      TrueNAS Server       │
                    │      192.168.20.181       │
                    │            │              │
                    │       ZFS Storage         │
                    │            │              │
                    │       NFS Shares          │
                    └────────────┼──────────────┘
                                 │
                         VMnet20 / Storage
                         192.168.20.0/24
                                 │
                ┌────────────────┴────────────────┐
                │                                 │
        ┌───────▼────────┐                ┌──────▼─────────┐
        │  CentOS Admin  │                │ Ubuntu Workload│
        │                │                │                │
        │ Griffindor     │                │ Slytherin      │
        │ storage-admin  │                │ storage-admin  │
        └────────────────┘                └────────────────┘
```

---

## What Was Implemented

### Storage

* TrueNAS virtual storage server
* Additional virtual data disks
* ZFS storage pool
* Mirrored storage layout
* Dedicated ZFS datasets
* Production and lab-oriented datasets
* NFS-backed centralized storage

### Networking

* Dedicated storage network
* Separate management/storage traffic
* Static TrueNAS storage IP
* Secondary Linux storage NICs
* Routing and default-gateway troubleshooting
* NFS traffic restricted to the storage subnet

### NFS

* NFS service configuration
* NFS share creation
* CentOS NFS client
* Ubuntu NFS client
* Manual NFS mounting
* Persistent NFS mounting through `/etc/fstab`
* NFS read/write validation

### Access Control

* Linux users and groups
* Department-style access model
* TrueNAS groups and ACLs
* UID/GID-based permissions
* Cross-server permission validation
* `storage-admin` administrative group
* Permission-denied simulations
* UID/GID mismatch simulation
* Maproot and Mapall behavior analysis

### Reliability & Recovery

* NFS service failure troubleshooting
* Network failure troubleshooting
* Persistent mount failure troubleshooting
* Storage-disk detection troubleshooting
* ZFS snapshot creation
* Simulated data modification/deletion
* File-level recovery from snapshot
* RPO-oriented recovery validation

### Performance & Monitoring

* FIO sequential read/write testing
* NFS client monitoring
* Network monitoring
* Disk I/O monitoring
* NFS statistics
* TCP connection inspection

---

## Environment

| Component              | Configuration             |
| ---------------------- | ------------------------- |
| Hypervisor             | VMware Workstation        |
| Storage Platform       | TrueNAS                   |
| Storage Protocol       | NFS                       |
| Filesystem             | ZFS                       |
| Linux Client 1         | CentOS                    |
| Linux Client 2         | Ubuntu                    |
| Management Network     | 192.168.10.0/24           |
| Storage Network        | 192.168.20.0/24           |
| TrueNAS Storage IP     | 192.168.20.181            |
| NFS Production Dataset | `storage_tank/production` |
| NFS Lab Dataset        | `storage_tank/nfs-lab`    |

---

# Storage Architecture

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

The project deliberately uses dedicated datasets instead of exporting the ZFS pool root directly.

---

# Identity & Access Model

### CentOS

```text
griffindor
├── Harry
├── Ron
├── Hermoine
└── Nevaille

storage-admin
└── Harry
```

### Ubuntu

```text
slytherin
├── Draco
├── Tom
├── Thodore
└── Blaise

storage-admin
└── Draco
```

The project demonstrates that NFS authorization is fundamentally affected by **numeric UID/GID identity**, not simply by matching usernames.

For example:

```text
CentOS:
Harry → UID 1112

Ubuntu:
Harry → different UID
```

Even though the username is identical, NFS can interpret the identities differently.

This behavior was intentionally reproduced as a failure scenario.

---

# Major Failure Simulations

This project intentionally introduced failures instead of only documenting successful deployment.

| Failure                               | Root Cause                                  | Resolution                                    |
| ------------------------------------- | ------------------------------------------- | --------------------------------------------- |
| NFS server unreachable                | Storage-network connectivity                | Verified NIC, route and TrueNAS connectivity  |
| `showmount` RPC failure               | NFS service/IP/export issue                 | Validated NFS service and share configuration |
| NFS permission denied                 | UID/GID / dataset permission / root mapping | Corrected identity and access configuration   |
| `chmod` operation not permitted       | NFS server-side permission model            | Investigated Maproot and dataset permissions  |
| NFS mount disappears after reboot     | Manual mount                                | Configured `/etc/fstab`                       |
| Persistent mount confusion            | Permission/state interpretation             | Validated with `findmnt` and `mount`          |
| CentOS storage NIC detected but no IP | Interface configuration                     | Corrected interface activation                |
| Package update failure                | Incorrect default route                     | Corrected default gateway/interface           |
| CentOS FastTrack repository failure   | Broken/obsolete repository metadata         | Disabled FastTrack                            |
| TrueNAS disk not visible              | VM disk discovery                           | Restarted TrueNAS VM                          |
| TrueNAS ACL cannot find Linux group   | Group existed only on Linux client          | Created corresponding group on TrueNAS        |
| Cross-server access failure           | UID/GID mismatch                            | Aligned numeric GID                           |
| Accidental/deleted files              | Simulated operational change                | Recovered files from ZFS snapshot             |

---

# Performance Validation

FIO was used to benchmark the NFS-mounted storage.

### Sequential Read

```text
Average bandwidth: 218 MiB/s
Average IOPS:       218
Runtime:            60 seconds
Block size:         1 MiB
```

### Sequential Write

```text
Average bandwidth: 128 MiB/s
Average IOPS:       127
Runtime:            60 seconds
Block size:         1 MiB
```

These values are **lab measurements**, not production performance guarantees. They depend on the VMware virtual hardware, host storage, virtual networking, workload pattern and NFS configuration.

---

# Monitoring

The project monitored multiple infrastructure layers:

```text
Application
     ↓
Filesystem
     ↓
NFS Client
     ↓
Network
     ↓
NFS Server
     ↓
ZFS
     ↓
Virtual / Physical Storage
```

Useful commands included:

```bash
nfsstat -m
nfsstat -c
iostat -xz 2 5
ip -s link
ss -tan
df -h
findmnt
mount
```

---

# Snapshot Recovery

A ZFS snapshot was created before intentionally modifying production-style test data.

The recovery workflow was:

```text
Initial Data
     ↓
ZFS Snapshot
     ↓
Data Modification / Deletion
     ↓
Snapshot Clone / Browse
     ↓
Identify Required Files
     ↓
Copy Files Back
     ↓
Validate Recovery
```

The lab deliberately avoided treating a snapshot rollback as the default file-recovery mechanism.

A snapshot is a point-in-time recovery mechanism, not automatically an independent backup.

---

# Scripting

Shell scripting was used to automate repetitive identity-management tasks.

Examples include:

```bash
useradd
groupadd
usermod
groupmod
```

Performance tests were also converted into reusable scripts:

```text
scripts/
├── identities.sh
├── perfmon-read.sh
└── perfmon-write.sh
```

---

# Engineering Lessons

The most important lessons from the project were:

1. **Network storage is a dependency chain.**

   NFS troubleshooting should begin with basic network connectivity before moving into NFS protocol or permission troubleshooting.

2. **NFS identity is numeric.**

   Matching usernames does not guarantee matching permissions. UID/GID consistency matters.

3. **Linux root is not automatically TrueNAS root.**

   NFS root mapping and dataset permissions determine what the client can actually do.

4. **Persistent mounts should be tested before rebooting.**

   Always validate `/etc/fstab` using:

   ```bash
   sudo mount -a
   ```

5. **Snapshots are not backups.**

   Snapshots provide point-in-time recovery on the same storage platform. Independent backup or replication provides a separate protection layer.

6. **Troubleshooting should be evidence-driven.**

   Commands such as `ip route`, `findmnt`, `nfsstat`, `iostat`, `ss`, and `df` provide evidence before configuration changes are made.

---

# Repository Structure

```text
architecture/       Architecture and network diagrams
centos-kvm/         CentOS/KVM infrastructure setup
truenas/            TrueNAS and ZFS configuration
nfs/                NFS server/client implementation
troubleshooting/    Failure simulations and remediation
validation/         Connectivity, storage and performance validation
scripts/            Reusable automation scripts
docs/               Engineering notes and lessons learned
screenshots/        Supporting implementation evidence
```

---

# Project Outcome

This project demonstrates an end-to-end Linux storage administration workflow:

```text
Design
  ↓
Deploy
  ↓
Configure
  ↓
Secure
  ↓
Mount
  ↓
Validate
  ↓
Break
  ↓
Troubleshoot
  ↓
Recover
  ↓
Measure
  ↓
Document
```

The focus is not only on making NFS work, but on understanding how storage, networking, identity, permissions, availability, monitoring and recovery interact in an infrastructure environment.
