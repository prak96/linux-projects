# Industry Problem 3 — NFS Performance Comparison & Monitoring

## Scenario

Network storage introduces additional processing and network dependency compared with local storage.

The objective was to measure NFS workload behavior rather than simply assume that the storage was performing correctly.

The test was performed against the NFS-mounted:

```text
/files/prod/griffindor/
```

---

# 1. Performance Test Tools

Ubuntu:

```bash
sudo apt install fio sysstat nfs-common -y
```

CentOS:

```bash
sudo dnf install fio sysstat nfs-utils -y
```

Primary tools:

```text
fio
nfsstat
iostat
ip
ss
```

---

# 2. Sequential Read Benchmark

Script:

```bash
fio --name=nfs-sequential-read \
    --directory=/files/prod/griffindor/ \
    --size=1G \
    --rw=read \
    --bs=1M \
    --direct=1 \
    --iodepth=16 \
    --runtime=60 \
    --time_based
```

The test measured:

* bandwidth
* IOPS
* completion latency
* latency percentiles
* CPU utilization
* I/O depth

---

# 3. Sequential Write Benchmark

```bash
fio --name=nfs-sequential-write \
    --directory=/files/prod/griffindor/ \
    --size=1G \
    --rw=write \
    --bs=1M \
    --direct=1 \
    --iodepth=16 \
    --runtime=60 \
    --time_based
```

---

# 4. Observed Results

## Sequential Read

Observed approximately:

```text
Bandwidth : 218 MiB/s
IOPS      : 218
Average latency : ~4.6 ms
```

The workload completed successfully with:

```text
err = 0
```

## Sequential Write

Observed approximately:

```text
Bandwidth : 128 MiB/s
IOPS      : ~128
Average latency : ~7.8 ms
```

The workload also completed successfully:

```text
err = 0
```

---

# 5. Important Interpretation

These numbers should **not** be presented as universal TrueNAS or NFS performance figures.

They are measurements from this specific lab environment.

The result is affected by:

* VMware virtualization
* virtual disk configuration
* host hardware
* VM resources
* virtual network
* NFS configuration
* ZFS configuration
* workload pattern
* block size
* test duration
* concurrent activity

Therefore, the correct engineering conclusion is:

> The benchmark establishes a baseline for this environment, rather than representing a production storage SLA.

---

# 6. Why Read and Write Results Differ

The observed read throughput was higher than write throughput.

This does not automatically identify the bottleneck.

Potential contributing layers include:

```text
fio
 ↓
Linux filesystem
 ↓
NFS client
 ↓
Network
 ↓
NFS server
 ↓
ZFS
 ↓
Virtual disk
 ↓
Physical storage
```

The correct approach is to correlate the benchmark with monitoring data before declaring a bottleneck.

---

# 7. NFS Client Monitoring

## NFS Mount Statistics

```bash
nfsstat -m
```

Useful for validating mounted NFS filesystem information.

## Client NFS Statistics

```bash
nfsstat -c
```

Useful for observing client-side NFS operation statistics.

---

# 8. Storage Monitoring

```bash
iostat -xz 2 5
```

This provides visibility into:

* utilization
* queue behavior
* latency
* throughput
* device saturation

A useful troubleshooting question is:

> Is the application waiting on the storage device, or is the delay occurring somewhere before the storage layer?

---

# 9. Network Monitoring

```bash
ip -s link
```

Useful for identifying:

* RX/TX traffic
* dropped packets
* errors
* interface statistics

For connection visibility:

```bash
ss -tan
```

This helps determine whether expected network sessions/connections are present.

---

# 10. Multi-Layer Monitoring Model

The project used the following troubleshooting hierarchy:

```text
Application
     ↓
Filesystem
     ↓
NFS Client
     ↓
Network
     ↓
NFS Server
     ↓
ZFS
     ↓
Virtual / Physical Disk
```

This prevents an engineer from immediately blaming storage when the actual issue may be:

```text
application
network
NFS
filesystem
```

---

# 11. Performance Troubleshooting Approach

When an NFS workload becomes slow:

### Step 1 — Confirm workload

```bash
fio ...
```

### Step 2 — Inspect NFS

```bash
nfsstat -m
nfsstat -c
```

### Step 3 — Inspect network

```bash
ip -s link
ss -tan
```

### Step 4 — Inspect Linux I/O

```bash
iostat -xz 2 5
```

### Step 5 — Inspect TrueNAS/ZFS

Check:

* pool health
* dataset behavior
* disk utilization
* ZFS statistics
* system resource utilization

The goal is correlation rather than assumption.

---

# 12. Engineering Lesson

Performance testing is meaningful only when the test parameters and environment are documented.

For example:

```text
Workload     : Sequential Read
Block Size   : 1 MiB
File Size    : 1 GiB
Runtime      : 60 sec
IO Depth     : 16
Filesystem   : NFS
Environment  : VMware lab
```

This makes future measurements comparable.

## Result

Successfully demonstrated:

* NFS read benchmarking
* NFS write benchmarking
* IOPS measurement
* throughput measurement
* latency observation
* NFS statistics
* network statistics
* Linux storage statistics
* layered infrastructure monitoring

The key outcome was learning to correlate **application → NFS → network → storage** instead of treating performance as a single-layer problem.
