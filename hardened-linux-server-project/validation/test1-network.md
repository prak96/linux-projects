# Test 1 — Network addressing and routing

## Commands

On each VM:

```bash
hostname
ip -br addr
ip route
```

On WEB-SRV01:

```bash
ip route get 172.27.10.101
ip route get 172.27.30.201
```

## Expected

- WEB-SRV01 has management and DMZ addresses on the intended interfaces.
- ADMIN-SRV01 is in `172.27.10.0/24`.
- TEST-SRV01 is in `172.27.30.0/24`.
- The NAT/default route is intentional and not duplicated across private NICs.

## Record actual result

- Date/time:
- Observed interface/address:
- Default route:
- Deviations:
- Result: PASS / FAIL
- Screenshot/evidence filename:
