# Permission Denied Troubleshooting

> Linux/NFS identity, UID/GID and TrueNAS ACL troubleshooting.

## 1. Important Diagnostic Distinction

A successful NFS mount does not guarantee successful file access.

The layers are:

```text
Network
   ↓
NFS service
   ↓
Export authorization
   ↓
Mount
   ↓
Identity mapping
   ↓
Dataset permissions / ACL
   ↓
File operation
```

If the mount works but:

```bash
touch file
```

fails, do not immediately troubleshoot the network.

---

# 2. Failure: `sudo touch` Returns Permission Denied

Example:

```bash
sudo touch /data/prod/ubuntu-workload/test.txt
```

Result:

```text
Permission denied
```

A second test:

```bash
chmod 777 /data/prod/ubuntu-workload/
```

may return:

```text
Operation not permitted
```

## Diagnosis

The NFS mount itself was functioning.

The investigation therefore moved to:

```text
UID/GID
Maproot / Mapall
Dataset permissions
ACL
```

---

# 3. Linux Root Is Not Automatically TrueNAS Root

A critical NFS concept:

```text
root on Linux client
        ≠
unrestricted root on NFS server
```

NFS identity mapping controls how client identities are represented on the server.

For this lab, Maproot was configured:

```text
Maproot User  = root
Maproot Group = wheel
```

The file operation then succeeded.

---

# 4. Maproot vs Mapall

### Maproot

Maps the client-side root identity.

Conceptually:

```text
Linux root
    ↓
TrueNAS Maproot identity
```

Other users retain their own identities.

### Mapall

Maps all client users to a common server-side identity.

Conceptually:

```text
root ─────┐
harry ────┤
ron ──────┤
          ↓
     Mapall identity
```

Mapall therefore removes individual identity distinctions.

---

# 5. UID/GID Troubleshooting

Check the client identity:

```bash
id harry
id ron
```

Check the group:

```bash
getent group griffindor
```

The important attributes are:

```text
Username
UID
Group
GID
```

Matching usernames alone does not guarantee matching identity.

For example:

```text
Client:
harry → UID 1115

Server:
harry → UID 2115
```

These are different identities from the filesystem's perspective.

---

# 6. Failure: TrueNAS ACL Does Not Recognize Linux Group

Example:

```text
griffindor
```

exists on the Linux client but cannot be selected in the TrueNAS ACL editor.

## Root Cause

The group exists only on the Linux client.

TrueNAS cannot automatically use an arbitrary remote local Linux group as a local ACL identity.

## Resolution

Create the corresponding group in TrueNAS:

```text
TrueNAS
 → Credentials
   → Groups
      → Add
```

Then configure the dataset ACL.

---

# 7. UID/GID Mismatch Simulation

The lab intentionally used different GIDs to demonstrate identity mismatch.

This is valuable because it demonstrates that:

```text
Same username
        ≠
Same identity
```

and:

```text
Same group name
        ≠
Same GID
```

When troubleshooting NFS permissions, always compare numeric IDs.

---

# 8. Permission Troubleshooting Commands

Client:

```bash
id
id <username>
getent passwd <username>
getent group <group>
ls -ln <path>
ls -ld <path>
```

Using numeric ownership is particularly useful:

```bash
ls -ln
```

because it exposes UID/GID directly instead of relying only on names.

---

# 9. Permission Decision Tree

```text
NFS mounted?
   |
   ├── NO → NFS/network troubleshooting
   |
   └── YES
        |
        File operation fails?
        |
        ├── NO → Access validated
        |
        └── YES
             |
             Check UID/GID
             |
             Check Maproot/Mapall
             |
             Check dataset permissions
             |
             Check ACL
             |
             Check UID/GID mismatch
```

---

# 10. Engineering Lesson

This exercise demonstrates an important enterprise storage principle:

> **Authentication, identity mapping and authorization are separate concepts.**

A user may successfully authenticate to a Linux system, successfully mount an NFS export, and still be denied access because the server-side identity does not have the required permissions.

This is directly applicable to:

* NFS
* NAS
* Linux file servers
* Active Directory-integrated storage
* LDAP
* enterprise identity management
* VMware workload storage
