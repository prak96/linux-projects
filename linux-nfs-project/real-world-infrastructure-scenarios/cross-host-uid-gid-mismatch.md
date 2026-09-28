# Industry Problem 1 — Cross-Server NFS Access & UID/GID Consistency

## Scenario

Two independent Linux servers consume centralized storage from the same TrueNAS NFS infrastructure.

```text
                       TrueNAS
                    192.168.20.181
                          |
                    storage_tank
                          |
                     NFS / NFSv4
                          |
              +-----------+-----------+
              |                       |
        centos-admin            ubuntu-workload
              |                       |
         griffindor              slytherin
```

The objective was to provide departmental access without assigning permissions individually to every user.

---

# 1. Mount the NFS Shares

For initial testing, the NFS mounts were intentionally configured as **non-persistent mounts**.

Example:

```bash
mount -t nfs4 \
192.168.20.181:/mnt/storage_tank/production \
/files/prod/centos-admin
```

Departmental share:

```bash
mount -t nfs4 \
192.168.20.181:/mnt/storage_tank/nfs-lab/griffindor \
/files/prod/griffindor
```

Restricted share:

```bash
mount -t nfs4 \
192.168.20.181:/mnt/storage_tank/nfs-lab/restricted \
/files/prod/adminsOnly
```

Validate:

```bash
findmnt -t nfs,nfs4
df -hT
mount | grep nfs
```

---

# 2. Validate Client Identity

Before testing permissions:

```bash
id harry
id ron
id hermoine
id nevaille
```

For Ubuntu:

```bash
id draco
id tom
id thodore
id blaise
```

Also verify group IDs:

```bash
getent group griffindor
getent group slytherin
getent group storage-admin
```

This prevents an important troubleshooting mistake:

> Assuming that identical usernames/group names automatically represent identical identities.

---

# 3. Configure TrueNAS ACLs

The TrueNAS dataset was configured with group-based ACLs.

Example:

```text
Dataset:
storage_tank/nfs-lab/griffindor

ACL:
griffindor
→ Allow
→ Full Control
→ Inherit
```

The corresponding group must exist on TrueNAS.

```text
TrueNAS
→ Credentials
→ Groups
→ Add
```

Do not attempt to add a remote Linux-only group directly into the TrueNAS ACL editor.

---

# 4. Maproot / Mapall Considerations

For this particular identity-permission exercise:

```text
Maproot User:  empty
Maproot Group: empty

Mapall User:   empty
Mapall Group:  empty
```

The reason is intentional.

The exercise needs client identities to remain distinguishable.

Conceptually:

```text
Harry
  ↓
UID
  ↓
NFS request
  ↓
TrueNAS

Ron
  ↓
UID
  ↓
NFS request
  ↓
TrueNAS
```

Using `Mapall` would cause client credentials to be mapped to the same configured TrueNAS identity and would therefore obscure this identity-based testing.

---

# 5. Permission Test

Logged in as Harry:

```bash
su - harry
```

Attempt:

```bash
touch /files/prod/griffindor/harry-test.txt
```

Then test with Ron:

```bash
su - ron
touch /files/prod/griffindor/ron-test.txt
```

The expected behavior is that members of `griffindor` can access their corresponding dataset when the numeric identity and ACL configuration are aligned.

---

# 6. Negative Test

Attempt to access a departmental share from an unauthorized user.

Example:

```bash
su - harry
touch /files/prod/slytherin/harry-test.txt
```

Expected result:

```text
Permission denied
```

This negative test is important because successful access alone does not prove that the authorization model is working correctly.

A good infrastructure test validates both:

```text
Authorized → ACCESS
Unauthorized → DENIED
```

---

# 7. UID/GID Mismatch Simulation

A deliberate mismatch was introduced.

Example:

```text
Linux:
griffindor → GID 5000

TrueNAS:
griffindor → different GID
```

Although the visible group name remained:

```text
griffindor
```

the underlying numeric identity differed.

Result:

```text
User
 ↓
Linux group
 ↓
GID mismatch
 ↓
NFS request
 ↓
TrueNAS ACL
 ↓
ACCESS DENIED
```

This produced a realistic NFS permission failure.

---

# 8. Root Cause Investigation

Instead of immediately changing permissions, verify the identity first:

```bash
id harry
id ron
getent group griffindor
```

On the storage side, verify the TrueNAS group's numeric GID.

The important troubleshooting question becomes:

> "Does the identity reaching the NFS server match the identity referenced by the ACL?"

rather than:

> "Does the group name look correct?"

---

# 9. Remediation

The TrueNAS group was recreated with the expected GID.

Because the existing group configuration could not simply be modified as required for the test, it was removed and recreated with the correct numeric ID.

The ACL was then reapplied to:

```text
storage_tank/nfs-lab/griffindor
```

After correcting the identity:

```bash
id harry
getent group griffindor
```

Access was retested.

The authorized users were then able to create/access files successfully.

---

# 10. Enterprise Engineering Lesson

This simulation demonstrates several production-relevant concepts:

### Identity is numeric

```text
Username → UID
Group → GID
```

NFS authorization behavior can therefore become confusing when multiple systems maintain independent local identity databases.

### Permissions should be group-oriented

Instead of managing:

```text
Harry
Ron
Hermoine
Nevaille
```

individually:

```text
griffindor
      ↓
Dataset ACL
```

provides a more maintainable authorization model.

### Troubleshooting must be evidence-driven

A permission failure should be investigated through:

```text
Identity
   ↓
UID/GID
   ↓
Mount
   ↓
NFS configuration
   ↓
Dataset ACL
   ↓
File permissions
```

rather than repeatedly changing permissions until access works.

---

# Validation Checklist

```bash
id <user>
getent passwd <user>
getent group <group>

findmnt -t nfs,nfs4
df -hT

ls -ld <mount-point>
ls -ln <mount-point>

touch <mount-point>/test-file
```

The `ls -ln` command is particularly useful because it exposes **numeric UID/GID values**, avoiding ambiguity caused by usernames and group names.

## Result

Successfully demonstrated:

* Multi-server NFS consumption
* Group-based access
* Positive and negative permission testing
* UID/GID mismatch
* Root-cause identification
* Identity correction
* ACL revalidation
