# NFS Permissions and Identity Management

## Why UID/GID Matters

NFS permissions are based on numeric identity.

The important relationship is:

```text
Username
   ↓
UID

Group
   ↓
GID
```

The username alone is not enough.

For example:

```text
CentOS
Harry → UID 1112

Another Linux system
Harry → different UID
```

The two accounts may have the same username but represent different identities to NFS.

---

# Identity Model

## CentOS

```text
griffindor
├── Harry
├── Ron
├── Hermoine
└── Nevaille

storage-admin
└── Harry
```

## Ubuntu

```text
slytherin
├── Draco
├── Tom
├── Thodore
└── Blaise

storage-admin
└── Draco
```

---

# TrueNAS Groups

A Linux group existing only on a remote client cannot simply be selected in the TrueNAS ACL editor.

The group must exist on TrueNAS or be supplied through an appropriate directory service.

For the lab:

```text
TrueNAS
 → Credentials
 → Groups
 → Add
```

The required GID was then aligned with the Linux environment where cross-host access was required.

---

# ACL Model

Example dataset:

```text
/mnt/storage_tank/nfs-lab/griffindor
```

ACL:

```text
Group: griffindor
Permission: Full Control
Flags: Inherit
```

Similar ACLs were created for the `storage-admin` group where required.

---

# UID/GID Mismatch Failure

A deliberate mismatch was introduced.

Initial state:

```text
Linux Group GID
      ≠
TrueNAS Group GID
```

Even though the group names matched, access failed.

### Symptom

Users belonging to the expected Linux group were unable to create/access files in the corresponding NFS share.

### Diagnosis

Check:

```bash
id harry
```

```bash
id ron
```

```bash
getent group griffindor
```

Compare the numeric GID against the corresponding TrueNAS group.

---

# Remediation

Align the numeric GID.

Where required:

```bash
groupmod -g <GID> <group>
```

Then ensure users belong to the correct group:

```bash
usermod -aG <group> <user>
```

Validate:

```bash
id <user>
```

The group was then re-associated with the TrueNAS ACL.

---

# Team Isolation

The `storage-admin` group demonstrates role-based access.

```text
Harry ──┐
        ├── storage-admin
Draco ──┘
```

This allows selected administrators from different Linux systems to access the restricted dataset without granting every user administrative access.

---

# Permission-Denied Scenario

Example:

```bash
touch /data/prod/ubuntu-workload/test.txt
```

Failure:

```text
Permission denied
```

Attempting:

```bash
chmod 777 /data/prod/ubuntu-workload
```

can also fail because the permission model is controlled server-side.

---

# Root Is Not Automatically Root

A common misconception is:

```text
sudo on Linux
=
root everywhere
```

This is incorrect for NFS.

The NFS server controls how client root credentials are mapped.

This is where TrueNAS `Maproot` becomes relevant.

---

# Maproot vs Mapall

| Feature      | Maproot                 | Mapall                |
| ------------ | ----------------------- | --------------------- |
| Scope        | Root client identity    | All client identities |
| Normal users | Preserve identity       | Mapped                |
| Root         | Mapped                  | Mapped                |
| Granularity  | Higher                  | Lower                 |
| Main purpose | Controlled root mapping | Common identity       |

Memory aid:

```text
Maproot = Map root
Mapall  = Map everyone
```

---

# Permission Testing Matrix

| User  | Group         | Dataset    | Expected |
| ----- | ------------- | ---------- | -------- |
| Harry | griffindor    | griffindor | Allowed  |
| Ron   | griffindor    | griffindor | Allowed  |
| Draco | slytherin     | griffindor | Denied   |
| Tom   | slytherin     | griffindor | Denied   |
| Harry | storage-admin | restricted | Allowed  |
| Draco | storage-admin | restricted | Allowed  |

The exact result should always be validated against the actual ACL and UID/GID state rather than assumed.

---

# Key Engineering Lesson

When troubleshooting NFS permissions, validate in this order:

```text
User
 ↓
UID
 ↓
Group
 ↓
GID
 ↓
TrueNAS group
 ↓
Dataset ACL
 ↓
NFS export
 ↓
Maproot/Mapall
 ↓
Client mount
```

Do not solve an identity problem by blindly using:

```bash
chmod 777
```

The objective is to understand the identity and authorization path.
