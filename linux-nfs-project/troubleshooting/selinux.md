# SELinux Troubleshooting

> SELinux troubleshooting reference for CentOS/RHEL-style Linux environments.

## 1. Why SELinux Belongs in the Troubleshooting Model

SELinux can deny an operation even when traditional Unix permissions appear correct.

Therefore:

```text
chmod / ownership
        ≠
SELinux authorization
```

For a permission failure, investigate both layers where applicable.

---

# 2. Check SELinux Status

```bash
getenforce
```

Possible states:

```text
Enforcing
Permissive
Disabled
```

More detailed information:

```bash
sestatus
```

---

# 3. Important Troubleshooting Principle

Do not immediately disable SELinux because an application fails.

Instead determine:

```text
Is SELinux actually generating the denial?
```

This prevents masking the real issue.

---

# 4. Separate Unix Permission Failure from SELinux Failure

First inspect:

```bash
ls -ld <path>
ls -l <file>
```

Then:

```bash
getenforce
```

If required, investigate AVC logs.

The troubleshooting model becomes:

```text
File operation fails
        ↓
Unix ownership / mode
        ↓
ACL
        ↓
SELinux context/policy
```

---

# 5. NFS Context

When troubleshooting NFS-related permission problems on SELinux-enabled Linux systems, do not assume every `Permission denied` is caused by SELinux.

First establish:

```text
NFS connectivity
NFS mount
UID/GID
Maproot/Mapall
Dataset ACL
```

Then investigate SELinux if the evidence points there.

---


# 6. Engineering Lesson

SELinux should be treated as an additional authorization layer rather than an obstacle to be disabled.

A good production troubleshooting practice is:

```text
Observe denial
    ↓
Confirm SELinux involvement
    ↓
Identify policy/context
    ↓
Correct policy/context
    ↓
Retest
```

Avoid:

```text
Application failed
    ↓
Disable SELinux
```

unless there is a deliberate, documented reason to do so.
