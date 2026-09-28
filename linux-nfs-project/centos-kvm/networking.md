# CentOS Storage Networking

## Network Design

The lab separates management traffic from storage/NFS traffic.

```text
Management
192.168.10.0/24

Storage
192.168.20.0/24
```

The CentOS server uses a dedicated storage NIC for NFS communication.

---

## Verify NIC Detection

```bash
ip a
```

Confirm that the storage interface exists.

If the interface is detected but has no address, inspect its configuration.

---

## Interface Activation

The lab encountered a case where the storage NIC was detected but no IP address was assigned.

The interface configuration was corrected and the interface was activated.

CentOS tools used:

```bash
nmtui
```

or the CentOS Web Console.

---

## Connectivity Validation

Test the TrueNAS storage IP:

```bash
ping 192.168.20.181
```

Check routing:

```bash
ip route
```

Determine the route used to reach TrueNAS:

```bash
ip route get 192.168.20.181
```

---

## Default Gateway Issue

A separate NAT interface was required for Internet/package access.

A wrong default route through the storage/management interface caused package connectivity problems.

The route was corrected so Internet-bound traffic used the NAT interface while storage traffic remained on VMnet20.

Example diagnostic:

```bash
ip route get 8.8.8.8
```

Expected behavior:

```text
8.8.8.8 via <NAT-GATEWAY> dev <NAT-INTERFACE>
```

---

## Engineering Principle

Do not troubleshoot NFS before validating:

```text
NIC
 ↓
IP Address
 ↓
Route
 ↓
Ping
 ↓
NFS Service
 ↓
Export
 ↓
Mount
 ↓
Permissions
```

This dependency-based approach was repeatedly useful during the project.
