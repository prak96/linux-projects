# Lessons Learned

## 1. Troubleshooting Must Follow Dependencies

When NFS failed, the most effective sequence was:

```text
NIC
 ↓
IP
 ↓
Route
 ↓
Ping
 ↓
NFS Service
 ↓
Export
 ↓
Mount
 ↓
Permissions
```

Jumping directly into NFS configuration can waste troubleshooting time when the underlying problem is networking.

---

## 2. UID/GID Is More Important Than Username

The project demonstrated that:

```text
Harry ≠ automatically the same identity everywhere
```

The numeric UID is what matters to the NFS permission model.

This was reproduced as a deliberate failure.

---

## 3. Root Mapping Requires Care

Running:

```bash
sudo
```

on a Linux client does not automatically provide unrestricted root access to the TrueNAS filesystem.

NFS server-side mapping determines how root credentials are handled.

---

## 4. Dedicated Datasets Improve Storage Organization

Instead of exposing the pool root:

```text
Pool
 ↓
Dedicated Dataset
 ↓
NFS Share
```

provides a cleaner boundary for access control and data protection.

---

## 5. Persistent Mounts Need Validation

A correct `/etc/fstab` entry is not enough.

Use:

```bash
sudo mount -a
```

before rebooting.

Then verify with:

```bash
findmnt
mount
df
```

---

## 6. Snapshots Are Not Backups

Snapshots provide point-in-time protection.

They do not automatically provide independent storage protection.

---

## 7. Performance Numbers Need Context

The FIO results from this project:

```text
Read  ≈ 218 MiB/s
Write ≈ 128 MiB/s
```

are lab measurements.

They depend on the virtual hardware, host storage, network and workload.

---

## 8. Evidence Is Better Than Assumptions

Useful troubleshooting evidence included:

```bash
ip route
ip a
findmnt
mount
nfsstat
iostat
ss
df
zpool status
zfs list
```

The project reinforced the importance of observing the system before changing it.

---

## 9. Scriipting Should Remove Repetition

Identity creation was converted into a shell script rather than repeatedly executing:

```text
useradd
groupadd
usermod
groupmod
```

The same principle was applied to performance testing.

---

## 10. Failure Simulation Creates More Learning Than Happy-Path Deployment

A successful NFS mount proves that NFS can work.

A failed NFS mount followed by:

```text
Evidence
 ↓
Root Cause
 ↓
Remediation
 ↓
Validation
```

demonstrates operational troubleshooting capability.

---

# Final Takeaway

The project evolved from:

```text
Deploy NFS
```

into:

```text
Design
→ Deploy
→ Secure
→ Validate
→ Break
→ Troubleshoot
→ Recover
→ Measure
→ Automate
→ Document
```

That is the operational mindset this project was intended to demonstrate.
