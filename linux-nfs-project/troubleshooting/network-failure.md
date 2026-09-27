# Network Failure Troubleshooting

> Network troubleshooting from the CentOS/Ubuntu + TrueNAS infrastructure lab.

## 1. Troubleshooting Methodology

For multi-NIC Linux systems, do not begin with the application.

Use:

```text
NIC detected
    ↓
NIC configured
    ↓
IP assigned
    ↓
Subnet correct
    ↓
Default gateway
    ↓
Routing decision
    ↓
DNS
    ↓
Internet / service connectivity
```

---

# 2. Failure: Storage NIC Detected but Not Configured

## Symptom

A secondary storage NIC was attached to the CentOS VM, but the NFS server could not be reached.

Check:

```bash
ip a
```

The interface was visible, but it did not have the expected storage-network IP address.

## Diagnosis

This established:

```text
Virtual NIC → detected
IP configuration → missing
```

The problem was therefore below the NFS layer.

## Resolution

Review the CentOS NetworkManager configuration.

Ensure the interface is configured to start automatically:

```text
ONBOOT=yes
```

Activate the interface using:

```bash
nmtui
```

or the appropriate NetworkManager tooling.

## Validation

```bash
ip a
```

Then:

```bash
ping -c 4 192.168.20.181
```

If connectivity succeeds, only then proceed to NFS troubleshooting.

### Engineering lesson

A detected NIC is not necessarily an operational NIC.

Always distinguish:

```text
Detected
Configured
Activated
Addressed
Reachable
```

---

# 3. Failure: Wrong Default Gateway in a Multi-NIC VM

## Scenario

The lab used separate networks for management/storage and Internet/NAT access.

Example:

```text
Management / Storage
192.168.20.0/24

NAT / Internet
192.168.232.0/24
```

A second NAT interface was available, but Internet traffic was still being sent through the wrong network.

## Diagnosis

Inspect routing:

```bash
ip route
```

Then ask Linux exactly which route it will use:

```bash
ip route get 8.8.8.8
```

This is more useful than simply looking at the interface list.

## Root Cause

The wrong interface had the effective default route.

## Resolution

Remove the incorrect default route where appropriate:

```bash
sudo ip route del default via 192.168.20.1 dev ens38
```

## Validation

```bash
ip route get 8.8.8.8
```

Expected lab result:

```text
8.8.8.8 via 192.168.232.2 dev ens33 src 192.168.232.104
```

Then:

```bash
ping -c 4 8.8.8.8
```

### Important

Do not blindly delete default routes on production systems.

First determine:

```bash
ip route
ip route get <destination>
```

and understand which interface should own the default route.

---

# 4. Failure: Internet Works but `dnf update` Fails

This was an important second-stage failure.

## Symptom

After correcting routing, Internet connectivity worked, but:

```bash
sudo dnf update -y
```

still failed.

The failure referenced the FastTrack repository:

```text
Couldn't resolve host name
Failed to download metadata for repo 'fasttrack'
```

## Diagnosis

At this point:

```text
NIC             → working
IP              → working
Routing         → working
Internet        → working
DNF             → failing
```

Therefore, the investigation moved from networking to repository configuration.

## Resolution

Disable the unnecessary FastTrack repository:

```bash
sudo dnf config-manager --set-disabled fasttrack
```

Verify:

```bash
sudo dnf repolist --enabled
```

Expected lab configuration:

```text
appstream
baseos
extras
```

Clean metadata:

```bash
sudo dnf clean all
sudo dnf makecache
```

Retry:

```bash
sudo dnf update -y
```

## Engineering lesson

This was an important troubleshooting boundary:

> Once lower-layer connectivity is proven, stop changing the lower layer.

A working `ping` does not prove that package repositories are correctly configured.

---

# 5. Ubuntu Multi-NIC Routing

The same principle applied to Ubuntu.

Inspect:

```bash
ip route
```

Determine the route:

```bash
ip route get 8.8.8.8
```

If the storage interface incorrectly owns the default route:

```bash
sudo ip route del default via 192.168.20.1 dev ens38
```

Then verify the NAT interface is selected.

---

# 6. Evidence-Based Network Troubleshooting

Use commands according to the layer being tested:

### Interface

```bash
ip a
```

### Interface statistics

```bash
ip -s link
```

### Routing

```bash
ip route
ip route get <destination>
```

### Gateway

```bash
ping -c 4 <gateway>
```

### Remote host

```bash
ping -c 4 <server>
```

### DNS

```bash
getent hosts <hostname>
```

### TCP connectivity

```bash
ss -tan
```

---

# 7. Network Decision Tree

```text
NIC visible?
   |
   ├── NO → Check VM / virtual NIC
   |
   └── YES
        |
        IP assigned?
        |
        ├── NO → Configure NetworkManager
        |
        └── YES
             |
             Correct subnet?
             |
             ├── NO → Fix IP configuration
             |
             └── YES
                  |
                  Correct route?
                  |
                  ├── NO → Fix routing
                  |
                  └── YES
                       |
                       Gateway reachable?
                       |
                       ├── NO → Network path
                       |
                       └── YES
                            |
                            DNS/service/repository?
```

---

# 8. Enterprise-Relevant Takeaways

This troubleshooting exercise demonstrates practical understanding of:

* Multi-homed Linux systems
* Default gateway selection
* Route verification
* NetworkManager
* Storage-network isolation
* NAT vs private network separation
* DNS/repository troubleshooting
* Evidence-based fault isolation

The key principle is:

> **Do not confuse network availability with application availability.**
