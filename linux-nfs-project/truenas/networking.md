# TrueNAS Networking

## Network Model

TrueNAS uses two logical network paths:

```text
Management Network
192.168.10.0/24

Storage Network
192.168.20.0/24
```

The storage interface uses:

```text
192.168.20.181/24
```

---

## Static Storage Address

The secondary storage NIC was configured with a static IP.

Example configuration:

```text
IPv4 DHCP: No
IPv6 Auto: No
Address: 192.168.20.181/24
```

Static addressing prevents the NFS endpoint from changing unexpectedly.

---

## NFS Network Restriction

The NFS share is intended to be accessible through:

```text
192.168.20.0/24
```

This keeps storage traffic on the dedicated storage network.

---

## NFS Service Binding

During troubleshooting, the NFS service binding was left unrestricted while establishing connectivity.

After successful deployment, binding NFS to the storage interface can provide a more controlled design.

---

## Validation

From Linux:

```bash
ping 192.168.20.181
```

Check the client route:

```bash
ip route
```

Verify the TrueNAS address:

```bash
ip addr
```

---

## Troubleshooting Principle

If the Linux client cannot ping the TrueNAS storage IP, stop NFS troubleshooting.

Resolve:

```text
NIC → IP → VLAN/VMnet → Route → Connectivity
```

first.
