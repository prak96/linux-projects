# ZFS Snapshot-Based File Recovery

## Scenario

A production-style NFS dataset was used to simulate an operational data-loss event.

Dataset:

```text
storage_tank/production
```

NFS endpoint:

```text
192.168.20.181:/mnt/storage_tank/production
```

---

## Initial State

The recovery directory contained:

```text
important.txt
application.conf
database-test.txt
```

The initial versions represented the baseline state.

---

## Snapshot

A ZFS snapshot was created:

```text
storage_tank/production@before-change
```

The snapshot timestamp was treated as the recovery-point reference.

---

## Simulated Change

After the snapshot:

```text
important.txt
→ Version 2

application.conf
→ Version 2

database-test.txt
→ Deleted
```

---

## Recovery Strategy

The project deliberately did not immediately roll back the entire dataset.

Instead:

```text
Snapshot
   ↓
Clone / Browse
   ↓
Identify required file
   ↓
Copy file
   ↓
Validate
```

A temporary recovery dataset was created from the snapshot.

The snapshot-derived data was then exposed through NFS and accessed from the Linux client.

---

## Why Not Immediately Roll Back?

A dataset-level rollback can revert the dataset to an earlier state.

That may remove legitimate changes made after the snapshot.

For individual-file recovery, a clone/browse/copy workflow provides a more granular recovery method.

---

## Recovery Validation

The recovered files were compared with the expected pre-change versions.

The test successfully restored the original data.

---

# Snapshot ≠ Backup

A snapshot remains on the same storage platform.

Therefore:

```text
Snapshot
→ Point-in-time recovery

Backup
→ Independent copy / protection layer
```

A stronger production architecture would include:

```text
Production
   │
   ├── Snapshot
   │
   ├── Backup
   │
   ├── Separate Storage
   │
   └── Offsite / Remote Copy
```

---

# Operational Lesson

A mature storage administrator should be able to demonstrate:

```text
Storage
 ↓
Snapshot
 ↓
Failure / Data Loss
 ↓
Recovery
 ↓
Validation
```

rather than simply creating a snapshot and declaring the data protected.
