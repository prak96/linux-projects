# Test 1 — Network addressing and routing

## Commands

On each VM:

```bash
hostname
ip -br addr
ip route
```

On Ubuntu-Workload:

```bash
ip route get 172.27.10.101
ip route get 172.27.30.201
```

## Expected

- Ubuntu-Workload has management and DMZ addresses on the intended interfaces.
- CentOS-Admin is in `172.27.10.0/24`.
- Ubuntu-Client is in `172.27.30.0/24`.
- The NAT/default route is intentional and not duplicated across private NICs.

## Record actual result

- Date/time:
- Observed interface/address:
- Default route:
- Deviations:
- Result: PASS / FAIL
- Screenshot/evidence filename:
