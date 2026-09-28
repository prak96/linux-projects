# Storage Validation

## ZFS

From the TrueNAS shell:

```bash
zpool status
```

```bash
zpool list
```

```bash
zfs list
```

---

## Dataset

Validate:

```text
storage_tank/production
storage_tank/nfs-lab
```

---

## NFS Filesystem

On Linux:

```bash
df -h
```

```bash
df -Th
```

```bash
findmnt
```

---

## Read Test

```bash
cat <file>
```

---

## Write Test

```bash
touch <mount-point>/test.txt
```

```bash
echo "NFS validation" > <mount-point>/validation.txt
```

---

## Cross-Client Test

Create a file from CentOS and verify it from Ubuntu.

Then perform the reverse.

This validates centralized storage visibility rather than merely validating that each client can mount independently.

---

## Permission Test

Repeat the same operation using different users/groups and compare:

```bash
id <user>
ls -l
```

The expected result must correspond to the TrueNAS ACL and UID/GID configuration.
