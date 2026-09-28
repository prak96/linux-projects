# Industry-Level Simulations

This section documents production-inspired infrastructure scenarios implemented on a VMware-based Linux + TrueNAS NFS lab.

The objective was not only to configure NFS storage, but to simulate operational situations commonly encountered by Linux, Systems, Virtualization, and Infrastructure Engineers:

* Centralized NFS storage consumption from multiple Linux servers
* UID/GID-based identity behavior
* Group-based access control
* Cross-server file access
* Permission and authorization failures
* Administrative access through shared groups
* NFS performance benchmarking
* Multi-layer infrastructure monitoring
* ZFS snapshot-based recovery
* File-level recovery without rolling back the live dataset

## Environment

```text
                         TrueNAS
                    192.168.20.181
                           |
                     ZFS Storage
                           |
                     NFS / NFSv4
                           |
              +------------+------------+
              |                         |
       centos-admin              ubuntu-workload
              |                         |
       Griffindor Group          Slytherin Group
       storage-admin             storage-admin
```

## Simulation Philosophy

Each scenario follows an operational pattern:

```text
Business / Infrastructure Requirement
                ↓
           Design
                ↓
          Configuration
                ↓
       Failure / Simulation
                ↓
          Observation
                ↓
       Root Cause Analysis
                ↓
             Fix
                ↓
        Validation / Evidence
                ↓
       Production Lesson
```

The emphasis is on **evidence-based troubleshooting and validation**, rather than simply demonstrating that a configuration command works.

## Scenarios

### Industry Problem 1 — Cross-Server NFS Access

Demonstrates centralized NFS storage consumed by independent Linux servers while maintaining group-based file access.

Key concepts:

* NFS client/server architecture
* UID/GID mapping
* TrueNAS dataset ACLs
* Linux groups
* NFS identity propagation
* Maproot / Mapall considerations
* Cross-server access
* UID/GID mismatch simulation

### Industry Problem 2 — Team Isolation

Demonstrates how a shared administrative group can provide controlled access across multiple Linux systems without making individual users owners of storage resources.

Key concepts:

* Group-based authorization
* Shared administrative access
* Consistent GIDs
* Dataset-level permissions
* Access isolation
* Least-privilege principles

### Industry Problem 3 — Performance & Monitoring

Measures NFS sequential read/write performance and observes the infrastructure across multiple layers.

Key concepts:

* `fio`
* IOPS
* bandwidth
* latency
* `nfsstat`
* `iostat`
* network statistics
* socket inspection
* storage/network bottleneck analysis

### Industry Problem 4 — Snapshot-Based Recovery

Simulates accidental file modification and deletion and recovers the required files from a ZFS snapshot.

Key concepts:

* ZFS snapshots
* Point-in-time recovery
* RPO
* File-level recovery
* Snapshot clone
* Recovery validation
* Snapshot vs backup
* Safer recovery compared with indiscriminate dataset rollback

## Engineering Takeaway

The simulations demonstrate an end-to-end infrastructure workflow:

```text
Linux Identity
      ↓
Network
      ↓
NFS
      ↓
TrueNAS
      ↓
ZFS Dataset
      ↓
ACL
      ↓
Performance
      ↓
Monitoring
      ↓
Recovery
```

This mirrors the way infrastructure issues are investigated in production: **from the client outward, using measurable evidence at every layer.**
