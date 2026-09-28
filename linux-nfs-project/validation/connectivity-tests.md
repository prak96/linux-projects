# Connectivity Validation

## TrueNAS → Linux

Validate basic reachability between TrueNAS and clients.

---

## Linux → TrueNAS

```bash
ping 192.168.20.181
```

---

## Route Validation

```bash
ip route
```

```bash
ip route get 192.168.20.181
```

---

## NFS Export

```bash
showmount -e 192.168.20.181
```

---

## NFS Mount

```bash
findmnt /data/prod/ubuntu-workload
```

or:

```bash
mount | grep -i production
```

---

## TCP Validation

```bash
ss -tan
```

---

## Expected Flow

```text
Client NIC
   ↓
192.168.20.0/24
   ↓
TrueNAS .181
   ↓
NFS service
   ↓
Export
   ↓
Mount
```

A failure at one layer should be resolved before moving to the next.
