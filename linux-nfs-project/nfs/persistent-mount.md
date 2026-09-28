# Persistent NFS Mounts with `/etc/fstab`

## Problem

A manually mounted NFS filesystem does not automatically reappear after a Linux reboot.

Manual mount:

```bash
mount -t nfs ...
```

is not sufficient for persistent infrastructure.

---

## `/etc/fstab`

Add:

```text
192.168.20.181:/mnt/storage_tank/production/ /data/prod/ubuntu-workload/ nfs defaults,_netdev 0 0
```

For CentOS:

```text
192.168.20.181:/mnt/storage_tank/production/ /files/prod/centos-admin/ nfs defaults,_netdev 0 0
```

---

## `_netdev`

The `_netdev` option identifies the filesystem as network-dependent.

This is important because NFS depends on:

```text
Network
   ↓
NFS Server
   ↓
Mount
```

rather than behaving like a local disk.

---

## Test Before Reboot

Never immediately reboot after editing `/etc/fstab`.

Run:

```bash
sudo mount -a
```

If successful, verify:

```bash
df -h
```

```bash
mount | grep -i production
```

```bash
findmnt /data/prod/ubuntu-workload
```

---

## Reboot Validation

```bash
sudo reboot
```

After reboot:

```bash
findmnt /data/prod/ubuntu-workload
```

and:

```bash
mount | grep -i production
```

Validate file accessibility.

---

## Important Troubleshooting Lesson

During the project, the mount appeared inconsistent when viewed through different commands.

Instead of assuming the mount was absent, multiple sources were checked:

```bash
df -hT
mount
findmnt
```

This is important because one command's output should not be treated as the sole source of truth when diagnosing a filesystem state.

---

## Operational Rule

Every `/etc/fstab` change should follow:

```text
Edit
 ↓
mount -a
 ↓
findmnt
 ↓
Read/Write test
 ↓
Reboot
 ↓
Validate again
```
