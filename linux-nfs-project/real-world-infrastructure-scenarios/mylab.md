# Lab Identity & Storage Model

## Objective

Before implementing access-control and failure scenarios, I established a multi-host identity and storage model.

The purpose was to simulate an environment where:

* Multiple Linux servers consume centralized NFS storage.
* Users belong to departmental groups.
* Storage permissions are assigned to groups rather than individual users.
* TrueNAS provides centralized dataset-level authorization.
* UID/GID behavior can be deliberately tested across Linux systems.

---

# 1. Linux Identity Model

## CentOS — `centos-admin`

| Users    | Group           |
| -------- | --------------- |
| Harry    | `griffindor`    |
| Ron      | `griffindor`    |
| Hermoine | `griffindor`    |
| Nevaille | `griffindor`    |
| Harry    | `storage-admin` |

## Ubuntu — `ubuntu-workload`

| Users   | Group           |
| ------- | --------------- |
| Draco   | `slytherin`     |
| Tom     | `slytherin`     |
| Thodore | `slytherin`     |
| Blaise  | `slytherin`     |
| Draco   | `storage-admin` |

The model intentionally represents two different departments consuming centralized storage.

```text
                 Centralized NFS Storage
                         |
             +-----------+-----------+
             |                       |
        centos-admin            ubuntu-workload
             |                       |
        griffindor               slytherin
             |                       |
       Harry/Ron/etc.          Draco/Tom/etc.
```

---

# 2. Identity Creation Through Shell Scripting

Instead of manually executing `useradd`, `groupadd`, and `usermod` repeatedly, I created an identity provisioning script.

Example:

```bash
#!/bin/bash

for usr in Harry
do
    sudo useradd "${usr}"
done

for grp in slytherin storage-admin
do
    sudo groupadd "${grp}"
done

for usr in Harry
do
    sudo usermod -aG storage-admin "${usr}"
done

for usr in Draco Tom Thodore Blaise Harry
do
    sudo usermod -aG slytherin "${usr}"
done
```

The script was stored on the NFS server and executed from the Linux environments with host-specific modifications.

### Why this matters

This introduces an important infrastructure engineering practice:

> Repetitive administrative operations should be made repeatable wherever practical.

The script also provides a starting point for future automation using:

* Bash
* Ansible
* Terraform where applicable
* CI/CD-driven infrastructure workflows

---

# 3. UID/GID Verification

NFS authorization is not based simply on the visible username.

The numeric UID/GID is critical.

Example:

```text
CentOS:
griffindor → GID 5000
storage-admin → GID 6000

Ubuntu:
slytherin → GID 1005
storage-admin → GID 1006
```

I deliberately used different IDs in parts of the lab so that UID/GID mismatch could later be simulated as an access-control failure.

Useful verification:

```bash
id harry
id ron
id draco

getent passwd harry
getent group griffindor

getent passwd draco
getent group slytherin
```

### Engineering principle

```text
Username
   ↓
UID

Group Name
   ↓
GID
```

For NFS identity behavior, the numeric identity is more important than the displayed name.

This becomes particularly important when multiple independent Linux systems access centralized storage.

---

# 4. TrueNAS Storage Structure

The storage layout was designed to separate production data, departmental data, restricted data, and backup-oriented storage.

```text
storage_tank
│
├── production
│
├── nfs-lab
│   ├── shared
│   ├── griffindor
│   ├── slytherin
│   └── restricted
│
└── backup
```

The lab used multiple virtual disks to simulate a storage environment rather than placing all workloads into a single dataset.

---

# 5. Dataset Design

Separate datasets provide an administrative boundary for:

* permissions
* snapshots
* quotas
* data organization
* NFS exports
* recovery operations

Example:

```text
storage_tank/nfs-lab/griffindor
storage_tank/nfs-lab/slytherin
storage_tank/nfs-lab/restricted
```

This allowed permissions to be applied at a dataset level rather than relying entirely on individual directories.

---

# 6. TrueNAS Group Integration

A Linux group existing only on a remote client cannot simply be selected in the TrueNAS ACL editor.

For example:

```text
Linux client:
griffindor
```

does not automatically mean:

```text
TrueNAS:
griffindor
```

The group must exist locally on TrueNAS or be supplied through an appropriate directory service.

Therefore, the lab created corresponding groups within:

```text
TrueNAS
→ Credentials
→ Groups
```

This provided the foundation for dataset ACL testing.

---

# 7. ACL Model

For the departmental datasets, group-based ACLs were used.

Example:

```text
Dataset:
storage_tank/nfs-lab/griffindor

ACL:
griffindor
    Allow
    Full Control
    Inherit
```

The same concept was later applied to:

```text
storage-admin
```

### Why group-based access?

Instead of:

```text
Harry → permission
Ron → permission
Hermoine → permission
Nevaille → permission
```

the model becomes:

```text
griffindor
      ↓
Dataset ACL
      ↓
All authorized members
```

This is easier to manage when users are added or removed from a department.

---

# 8. Deliberate UID/GID Mismatch

One of the most valuable simulations in this project was deliberately creating a mismatch between the Linux group identity and the corresponding TrueNAS group.

Example:

```text
Linux:
griffindor → GID 5000

TrueNAS:
griffindor → different GID
```

The group name appears identical, but the numeric identity differs.

This was later demonstrated as an authorization failure.

After recreating the TrueNAS group using the same GID expected by the Linux client, access succeeded.

This demonstrates a real operational lesson:

> When troubleshooting NFS permissions, never stop at the username/group name. Verify the numeric UID/GID.

---

# 9. Lab Success Criteria

The lab identity/storage model was considered successful when:

* Users could be created consistently.
* Groups could be assigned.
* UID/GID values could be verified.
* TrueNAS groups could be mapped into dataset ACLs.
* Linux clients could consume NFS datasets.
* Group-based access could be tested.
* UID/GID mismatch could be deliberately reproduced.
* Correcting the numeric identity restored expected access.

This baseline enabled the subsequent industry-problem simulations.
