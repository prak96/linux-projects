# Persistent NFS Mount / fstab Troubleshooting

> Troubleshooting persistent NFS mounts across Linux reboot cycles.

## 1. Failure: NFS Mount Disappears After Reboot

## Symptom

The NFS share worked before reboot:

```text
TrueNAS
   ↓
NFS
   ↓
Linux mount point
```

After reboot, the mount was missing.

## Root Cause

A manually mounted NFS share is not automatically persistent.

A persistent mount must be defined in:

```text
/etc/fstab
```

---

# 2. Configure Persistent Mount

Example:

```fstab
# TrueNAS NFS Production Share
192.168.20.181:/mnt/storage_tank/production/ /data/prod/ubuntu-workload/ nfs defaults,_netdev 0 0
```

The fields are:

```text
NFS server/export
        ↓
Mount point
        ↓
Filesystem type
        ↓
Mount options
        ↓
Dump
        ↓
fsck/pass
```

---

# 3. Why `_netdev` Matters

NFS is a network filesystem.

The:

```text
_netdev
```

option tells Linux that the filesystem depends on network availability.

This helps prevent the system from treating the NFS filesystem like a local disk during boot.

---

# 4. Validate Before Reboot

This is a critical operational practice.

Do not immediately reboot after modifying `/etc/fstab`.

Run:

```bash
sudo mount -a
```

If there is no output, verify:

```bash
findmnt /data/prod/ubuntu-workload/
```

and:

```bash
mount | grep production
```

Also test:

```bash
df -hT | grep production
```

---

# 5. Validate Actual File Access

A mount appearing in `findmnt` is not enough.

Perform an actual workload test:

```bash
sudo touch /data/prod/ubuntu-workload/test.txt
```

Then:

```bash
ls -ltr /data/prod/ubuntu-workload/
```

This validates:

```text
Mount
+
Filesystem access
+
Permissions
```

---

# 6. Failure: Mount Missing After Reboot

Troubleshoot in this order:

```text
fstab entry
    ↓
mount point exists
    ↓
network available
    ↓
NFS server reachable
    ↓
NFS service available
    ↓
export accessible
    ↓
mount successful
```

Check:

```bash
grep -n "production" /etc/fstab
```

Then:

```bash
sudo mount -a
```

Check:

```bash
findmnt /data/prod/ubuntu-workload/
```

---

# 7. Verify Mount Point

```bash
ls -ld /data/prod/ubuntu-workload/
```

The local mount point must exist.

If required:

```bash
sudo mkdir -p /data/prod/ubuntu-workload/
```

---

# 8. Compare Mount Verification Commands

Use multiple views:

```bash
findmnt
```

```bash
mount
```

```bash
df -hT
```

They provide different perspectives.

Do not declare a mount broken simply because one command does not display it as expected.

---

# 9. Safe fstab Troubleshooting

A malformed `/etc/fstab` can affect boot behaviour.

Therefore:

```bash
sudo cp /etc/fstab /etc/fstab.backup
```

before major edits.

After modification:

```bash
sudo mount -a
```

Only reboot after the configuration has been successfully validated.

---

# 10. Persistent-Mount Decision Tree

```text
Mount disappeared after reboot
          |
          v
Entry present in /etc/fstab?
      /             \
    NO               YES
    |                 |
Add entry       mount -a fails?
                      / \
                    YES  NO
                     |    |
             Check network  |
             /NFS/export    |
                            v
                       findmnt
                            |
                       File access?
```

---

# 11. Engineering Lesson

The difference between:

```text
Manual mount
```

and:

```text
Persistent mount
```

is operational reliability.

A production administrator should validate not only:

> "Can I mount it?"

but also:

> "Will the system automatically recover the mount after reboot?"

This is why `/etc/fstab`, `_netdev`, `mount -a`, `findmnt`, and post-reboot validation are important operational skills.
