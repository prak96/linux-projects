# TrueNAS Installation

## Role

TrueNAS acts as the centralized storage platform for the Linux environment.

The project uses TrueNAS to provide:

* ZFS storage
* Datasets
* NFS shares
* ACLs
* Snapshots
* Recovery workflows
* Storage monitoring

---

## Virtual Hardware

The TrueNAS VM was deployed in VMware Workstation with additional virtual data disks.

The project initially attached two 40 GB data disks for the production storage configuration.

---

## Storage Design

The project uses dedicated data disks instead of relying only on the TrueNAS boot disk.

The production pool uses a mirrored disk layout for redundancy.

---

## Post-Disk Configuration

After attaching additional virtual disks, the disks were initially not visible in the TrueNAS interface.

### Root Cause

The newly attached disks were not immediately discovered by the TrueNAS VM.

### Resolution

Restart the TrueNAS VM after adding the virtual disks.

After restart, the disks became visible and available for pool configuration.

---

## Validation

Verify:

* TrueNAS boots correctly
* Web UI accessible
* Data disks visible
* Network interfaces visible
* Storage pool available

---

## Engineering Note

A storage platform should not be considered ready simply because the TrueNAS Web UI is accessible.

The validation sequence should continue through:

```text
VM
 ↓
NIC
 ↓
Disk
 ↓
ZFS Pool
 ↓
Dataset
 ↓
NFS Share
 ↓
Linux Client
 ↓
Read/Write
```
