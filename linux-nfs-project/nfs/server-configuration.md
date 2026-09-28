# NFS Server Configuration

## TrueNAS NFS Service

TrueNAS provides the NFS server functionality.

The primary production export used in the project is:

```text
/mnt/storage_tank/production
```

---

## Service Validation

From TrueNAS:

```text
System
 → Services
 → NFS
```

Verify:

* NFS service running
* Start automatically enabled
* Correct protocol configuration
* Appropriate network/share configuration

---

## NFS Share

The production dataset:

```text
storage_tank/production
```

is exposed through NFS.

Client network:

```text
192.168.20.0/24
```

---

## Export Validation

From Linux:

```bash
showmount -e 192.168.20.181
```

Expected export:

```text
/mnt/storage_tank/production
```

---

## Security Boundary

The NFS share should be restricted to the intended storage subnet or authorized hosts.

Example:

```text
192.168.20.0/24
```

Avoid accidentally authorizing the management network.

---

## Maproot / Mapall

For the permissions lab, Maproot and Mapall were intentionally tested.

For identity-preserving access:

```text
Maproot User: empty
Maproot Group: empty
Mapall User: empty
Mapall Group: empty
```

This allows client identity behavior to remain visible for the UID/GID exercises.

---

## Important Concept

`Maproot` and `Mapall` are identity-mapping controls.

```text
Maproot
→ maps root

Mapall
→ maps all client users
```

Do not use Mapall casually in an environment where individual user identity and permissions are important.
