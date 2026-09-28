# TrueNAS Data Protection and Configuration Notes

## Scope

This project explored multiple TrueNAS data-protection mechanisms.

These should not be treated as equivalent.

---

## ZFS Snapshots

Snapshots provide point-in-time recovery for a dataset.

Useful for:

* accidental deletion
* unwanted modification
* short-term recovery
* configuration/data changes
* RPO-oriented recovery points

Example:

```text
storage_tank/production@before-change
```

---

## Periodic Snapshots

TrueNAS can create snapshots automatically according to a defined schedule.

Example:

```text
Every 1 hour
     ↓
Snapshot
     ↓
Retain for 7 days
```

---

## Cloud Sync

Cloud Sync can synchronize data with supported cloud/object-storage destinations.

This is different from a local ZFS snapshot because the destination is external to the primary storage system.

---

## Rsync

Rsync provides file-level synchronization with another system.

Typical model:

```text
TrueNAS
   ↓
Rsync
   ↓
Linux / NAS / Generic Server
```

---

## ZFS Replication

Replication can transfer ZFS datasets/snapshots to another ZFS/TrueNAS system.

Typical model:

```text
Primary TrueNAS
      ↓
ZFS Replication
      ↓
Secondary TrueNAS
```

---

## Snapshot ≠ Backup

A snapshot remains dependent on the same storage platform.

Therefore:

```text
Snapshot
≠
Independent Backup
```

A more complete protection model is:

```text
Production Dataset
       │
       ├── ZFS Snapshot
       │
       ├── Backup
       │
       ├── Separate Storage
       │
       └── Offsite / Remote Copy
```

---

## Important Documentation Rule

Do not describe a local ZFS snapshot as an independent backup.

The project demonstrates snapshot-based recovery, while a production architecture would normally require an additional independent backup or replication layer.
