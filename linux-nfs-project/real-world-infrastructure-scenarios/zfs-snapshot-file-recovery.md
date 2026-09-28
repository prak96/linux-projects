# Industry Problem 4 — ZFS Snapshot-Based Recovery

## Scenario

A production-like NFS dataset was used to simulate accidental modification and deletion of application data.

Dataset:

```text
storage_tank/production
```

NFS export:

```text
192.168.20.181:/mnt/storage_tank/production
```

The recovery objective was to restore selected files from a known point-in-time state **without unnecessarily rolling back the entire live dataset**.

---

# 1. Create Recovery Test Data

On the CentOS NFS client:

```bash
cd /files/prod/centos-admin/recovery
```

Created:

```text
important.txt
application.conf
database-test.txt
```

Initial state:

```text
important.txt
Version 1

application.conf
port=8080
environment=production
version=1

database-test.txt
Database backup test - Version 1
```

A baseline was captured:

```bash
date

find . -maxdepth 1 -type f \
-printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n'
```

---

# 2. Create ZFS Snapshot

In TrueNAS:

```text
Datasets
→ storage_tank
→ production
→ Snapshot
```

Snapshot:

```text
before-change
```

Conceptually:

```text
Live Dataset
     |
     v
Version 1
     |
     v
ZFS Snapshot
before-change
```

The snapshot represents the dataset at that point in time.

---

# 3. Simulate Data Modification

After the snapshot, the files were deliberately modified.

```text
important.txt
Version 1 → Version 2

application.conf
version=1 → version=2

database-test.txt
DELETED
```

The live dataset now represented:

```text
important.txt       → Version 2
application.conf    → Version 2
database-test.txt   → Deleted
```

This created a realistic recovery requirement.

---

# 4. Define the Recovery Point

The snapshot:

```text
storage_tank/production@before-change
```

became the recovery reference.

This represents an RPO checkpoint:

```text
Current State
     |
     | data modification
     |
     v
Recovery Required
     |
     v
before-change snapshot
```

---

# 5. Why I Did Not Immediately Roll Back

A dataset rollback can restore the dataset to an earlier state.

That can be dangerous when the live dataset contains legitimate changes made after the snapshot.

For example:

```text
Snapshot
Version 1
   |
   +---- legitimate change
   |
   +---- accidental change
   |
   +---- another legitimate change
   |
Current dataset
```

A full rollback can potentially remove changes that should be retained.

Therefore, for this simulation, the objective was **granular recovery**.

---

# 6. Snapshot-Based File Recovery

The snapshot was exposed using a temporary clone/recovery workflow.

Conceptually:

```text
storage_tank/production
          |
          v
   before-change
      snapshot
          |
          v
temporary recovery clone
          |
          v
NFS mount
          |
          v
required files
```

A temporary recovery dataset was created:

```text
production-recovery-restore
```

The recovery dataset was then exposed through NFS and mounted on the CentOS client.

---

# 7. Validate Snapshot Contents

On the recovery mount:

```bash
ls -ltr
```

The snapshot version contained:

```text
important.txt       → Version 1
application.conf    → Version 1
database-test.txt   → Present
```

This confirmed that the snapshot contained the desired recovery state.

---

# 8. Recover Individual Files

Instead of replacing the complete live dataset, files were copied individually.

Example:

```bash
cp \
/files/prod/centos-admin-restore/recovery/database-test.txt \
/files/prod/centos-admin/recovered/
```

Then:

```text
important.txt
application.conf
database-test.txt
```

could be restored selectively.

---

# 9. Validate Recovery

Check files:

```bash
ls -ltr /files/prod/centos-admin/recovered/
```

Inspect content:

```bash
cat /files/prod/centos-admin/recovered/important.txt

cat /files/prod/centos-admin/recovered/application.conf

cat /files/prod/centos-admin/recovered/database-test.txt
```

The objective was to confirm:

```text
Expected snapshot state
        ↓
Recovered file
        ↓
Content validation
```

Recovery is not considered complete merely because a copy command succeeds.

---

# 10. Snapshot vs Backup

This distinction is critical.

## Snapshot

```text
TrueNAS
   |
Dataset
   |
ZFS Snapshot
```

Provides point-in-time recovery on the storage system.

Useful for:

* accidental deletion
* accidental modification
* short-term recovery
* configuration mistakes
* user mistakes

## Backup

A stronger backup architecture separates the recovery copy from the primary storage system.

```text
Production Dataset
       |
       +---- ZFS Snapshot
       |
       +---- Backup
                |
          Separate Storage
                |
             Offsite
```

A snapshot alone should therefore not be described as a complete disaster-recovery strategy.

---

# 11. Periodic Snapshots

TrueNAS can automate snapshot creation through periodic snapshot tasks.

Example conceptual policy:

```text
Every 1 hour
     ↓
Create snapshot
     ↓
Retain for defined period
```

This provides recurring recovery points for:

* accidental deletion
* file version recovery
* short-term rollback points
* RPO-oriented protection

Retention should be designed according to business requirements rather than selecting an arbitrary duration.

---

# 12. Recovery Decision Model

The recovery workflow used in this project was:

```text
Data Loss
    |
    v
Identify required recovery point
    |
    v
Locate snapshot
    |
    v
Validate snapshot contents
    |
    v
Expose snapshot / clone
    |
    v
Recover required files
    |
    v
Validate recovered data
    |
    v
Keep current live dataset intact
```

---

# 13. Why This Matters Operationally

The important lesson is not simply:

> "I created a ZFS snapshot."

The more valuable workflow is:

```text
NFS Storage
     ↓
ZFS Snapshot
     ↓
Simulated Data Loss
     ↓
Recovery Point Identification
     ↓
Snapshot Exposure
     ↓
File-Level Recovery
     ↓
Validation
```

This demonstrates an operational recovery process rather than a configuration-only exercise.

---

# Engineering Lessons

### Snapshot is not backup

A snapshot remains associated with the same storage infrastructure unless replicated elsewhere.

### Recovery requires validation

A successful `cp` does not prove that the correct version was recovered.

### Avoid unnecessary destructive recovery

For individual-file incidents, file-level recovery can be safer than immediately reverting the entire dataset.

### RPO matters

The snapshot timestamp establishes the point in time from which data can be recovered.

### Recovery strategy depends on the incident

Different incidents may require:

```text
File recovery
     OR
Dataset rollback
     OR
Backup restoration
     OR
Offsite disaster recovery
```

The recovery method should therefore be selected based on the scope of the failure.

## Result

Successfully demonstrated an end-to-end recovery workflow:

```text
Production NFS Dataset
        ↓
ZFS Snapshot
        ↓
Intentional Data Modification
        ↓
File Deletion
        ↓
Snapshot Validation
        ↓
Temporary Recovery Dataset
        ↓
NFS Recovery Mount
        ↓
File-Level Restoration
        ↓
Data Validation
```

This provided practical exposure to **ZFS snapshots, NFS recovery, RPO concepts, controlled restoration, and the distinction between snapshots and backups**.
