# CentOS Infrastructure / KVM Environment

## Purpose

This section documents the CentOS infrastructure used as one of the Linux NFS clients and administrative workload servers.

The project uses CentOS as the `centos-admin` workload and storage client.

---

## Role

The CentOS server is responsible for:

* NFS client access
* Storage-network connectivity
* Linux user/group management
* Permission testing
* FIO performance testing
* Snapshot recovery testing
* Monitoring and troubleshooting

---

## Packages

NFS-related packages were validated using:

```bash
dnf list | grep -i nfs
```

Required NFS utilities include:

```bash
sudo dnf install nfs-utils -y
```

Performance and monitoring tooling:

```bash
sudo dnf install fio sysstat -y
```

---

## Web Console

CentOS Cockpit/Web Console was also used during the lab for infrastructure administration.

Example:

```text
https://<CENTOS-IP>:9090/
```

---

## Validation

Verify the operating system:

```bash
cat /etc/os-release
```

Verify interfaces:

```bash
ip a
```

Verify routes:

```bash
ip route
```

Verify NFS utilities:

```bash
showmount --version
```

---

## Engineering Note

The purpose of this server in the lab is not simply to act as an NFS client.

It provides a realistic Linux administration endpoint from which storage connectivity, identity, permissions, performance and recovery behavior can be tested.
