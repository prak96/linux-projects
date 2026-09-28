# NFS Failure Troubleshooting

> NFS client/server troubleshooting performed against the TrueNAS storage network.

## 1. NFS Troubleshooting Model

An NFS failure can occur at several independent layers:

```text
Client NIC
    ↓
IP / Routing
    ↓
Server Reachability
    ↓
NFS Service
    ↓
NFS Protocol / RPC
    ↓
Export Authorization
    ↓
Share Network Restriction
    ↓
Mount
    ↓
UID/GID / ACL
    ↓
File Operation
```

Do not troubleshoot all layers simultaneously.

---

# 2. Failure: `showmount` Returns RPC / Connection Refused

## Symptom

```bash
showmount -e 192.168.20.181
```

returned an RPC/portmapper connection error.

## Step 1 — Test Network Connectivity

```bash
ping -c 4 192.168.20.181
```

If this fails:

> Stop NFS troubleshooting.

Check:

```bash
ip a
ip route
```

and verify:

```text
Ubuntu/CentOS storage NIC
        ↓
VMnet20
        ↓
TrueNAS storage NIC
```

---

# 3. Verify NFS Service

On TrueNAS:

```text
System
 → Services
   → NFS
```

Verify:

```text
NFS = Running
Start Automatically = Enabled
```

Then retry:

```bash
showmount -e 192.168.20.181
```

---

# 4. Verify NFS Binding

If the service is running but inaccessible, inspect its bind configuration.

For initial troubleshooting, leaving the bind-address field empty allows the service to listen on available addresses.

Once the environment is validated, binding NFS specifically to the storage interface can be used to demonstrate deliberate network isolation.

Example:

```text
Management:
192.168.10.x

Storage:
192.168.20.181
```

---

# 5. Verify Export Authorization

The NFS server must authorize the client.

Example:

```text
NFS Server:
192.168.20.181

NFS Client:
192.168.20.x
```

A common mistake is confusing:

```text
Server IP
```

with:

```text
Client IP
```

The export authorization needs to permit the system attempting to mount the share.

---

# 6. Verify Share Network

For this lab:

```text
192.168.20.0/24
```

was used as the storage network.

This provides a logical separation:

```text
192.168.20.0/24 → NFS clients
192.168.10.0/24 → Management
```

This demonstrates that:

> Network reachability and service authorization are separate controls.

---

# 7. Verify the Actual Server Interface

On TrueNAS:

```bash
ip addr
```

Confirm the intended storage interface owns:

```text
192.168.20.181
```

When a server has multiple NICs, always validate the IP/interface mapping before debugging the service.

---

# 8. NFS Protocol Consideration

For initial troubleshooting, a simple NFS configuration is preferable.

If using `showmount`, remember that it is primarily associated with NFSv3/RPC-oriented discovery.

Therefore:

```text
showmount failure
```

does not automatically mean:

```text
NFSv4 mount failure
```

If the environment is deliberately configured as NFSv4-only, use an NFSv4-appropriate mount test rather than relying exclusively on `showmount`.

---

# 9. Successful NFS Troubleshooting Sequence

```text
ping server
     ↓
NFS service running
     ↓
Correct server IP/interface
     ↓
Correct client authorization
     ↓
Correct share network
     ↓
Correct protocol
     ↓
Mount
     ↓
File access
```

---

# 10. Evidence Collection

Client:

```bash
ip a
ip route
ping -c 4 <NFS_SERVER>
showmount -e <NFS_SERVER>
findmnt
mount
nfsstat -m
```

Server-side investigation should include:

```text
NFS service state
Export configuration
Authorized networks/hosts
Bind configuration
Dataset permissions
ACL configuration
```

---

# 11. Key Engineering Lesson

NFS troubleshooting is not simply:

```text
"Is NFS running?"
```

The correct question is:

> **At which layer is the NFS communication path failing?**

This approach transfers directly to enterprise NAS, SAN-adjacent Linux workloads, VMware storage networks and production file-service environments.
