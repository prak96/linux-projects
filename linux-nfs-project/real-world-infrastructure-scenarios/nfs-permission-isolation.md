# Industry Problem 2 — Team Isolation Through Group-Based Access

## Scenario

An infrastructure environment often needs a small administrative group to access restricted storage without giving broad access to every user.

The scenario simulated this requirement using:

```text
storage-admin
```

Membership:

```text
CentOS:
Harry → storage-admin

Ubuntu:
Draco → storage-admin
```

Target dataset:

```text
storage_tank/nfs-lab/restricted
```

---

# 1. Objective

Demonstrate:

* Group-based authorization
* Cross-server administrative access
* Consistent GID management
* Restricted dataset access
* Positive and negative authorization testing

The intended access model:

```text
                  restricted
                      |
               storage-admin
                  /       \
              Harry       Draco
                |           |
             CentOS       Ubuntu
```

Other users should not automatically receive access merely because they can access other NFS datasets.

---

# 2. Identity Preparation

Verify Harry:

```bash
id harry
```

Verify Draco:

```bash
id draco
```

Verify the group:

```bash
getent group storage-admin
```

The numeric GID must be consistent for the identity model being tested.

Example:

```text
storage-admin → GID 6000
```

---

# 3. Correct the Ubuntu GID

The Ubuntu environment initially had a different GID for `storage-admin`.

The GID was changed:

```bash
sudo groupmod -g 6000 storage-admin
```

Draco was then added:

```bash
sudo usermod -aG storage-admin draco
```

Validate:

```bash
id draco
getent group storage-admin
```

### Important

Existing sessions may not immediately reflect new group membership.

A new login session can be used to validate the updated supplementary groups.

```bash
su - draco
id
```

---

# 4. Configure TrueNAS Authorization

Create/verify the corresponding TrueNAS group:

```text
TrueNAS
→ Credentials
→ Groups
→ storage-admin
```

Ensure the intended GID is aligned with the identity model.

Then configure the dataset ACL:

```text
storage_tank/nfs-lab/restricted
```

Example:

```text
storage-admin
    Allow
    Full Control
    Inherit
```

---

# 5. Positive Access Test

From CentOS as Harry:

```bash
su - harry
touch /files/prod/adminsOnly/harry-test.txt
```

From Ubuntu as Draco:

```bash
su - draco
touch <restricted-mount>/draco-test.txt
```

Both users should be able to access the restricted dataset when their numeric identity and ACL configuration are aligned.

---

# 6. Negative Access Test

Test a user who is not a member of `storage-admin`.

Example:

```bash
su - hermoine
touch /files/prod/adminsOnly/hermoine-test.txt
```

Expected:

```text
Permission denied
```

This establishes that access is controlled by group membership rather than simply by NFS reachability.

---

# 7. Shared File Exchange

A useful operational test is to validate that members of the same administrative group can exchange data.

Harry:

```bash
echo "Message from Harry" \
> /files/prod/adminsOnly/harry-note.txt
```

Draco:

```bash
cat /files/prod/adminsOnly/harry-note.txt
```

Then reverse the test.

Draco:

```bash
echo "Message from Draco" \
> /files/prod/adminsOnly/draco-note.txt
```

Harry:

```bash
cat /files/prod/adminsOnly/draco-note.txt
```

---

# 8. Why This Is More Realistic Than Individual Permissions

An organization should not have to modify a dataset ACL every time an employee joins or leaves a team.

Instead:

```text
Employee
   ↓
Group membership
   ↓
Dataset ACL
   ↓
Resource access
```

User lifecycle:

```text
New administrator
      ↓
Add to storage-admin
      ↓
Access inherited

Administrator leaves team
      ↓
Remove from storage-admin
      ↓
Access removed
```

This separates **identity lifecycle** from **resource authorization**.

---

# 9. Security Boundary

The model intentionally avoids giving every Linux user access to the restricted dataset.

```text
griffindor
    ↓
Departmental data

slytherin
    ↓
Departmental data

storage-admin
    ↓
Restricted administrative data
```

This provides a simple demonstration of role/group-based access segmentation.

---

# 10. Engineering Lesson

The most important lesson from this scenario was:

> Group-based authorization is easier to operate and audit than maintaining individual user permissions across multiple systems.

However, group names alone are insufficient for this NFS scenario.

Always validate:

```text
User
 ↓
UID
 ↓
Group
 ↓
GID
 ↓
NFS identity
 ↓
TrueNAS ACL
```

## Result

Successfully demonstrated:

* Restricted dataset access
* Cross-server administrative group
* Shared storage access
* Consistent GID requirement
* Positive authorization
* Negative authorization
* Group-based access lifecycle
