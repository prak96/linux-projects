# Test 2 — SSH authentication and source restrictions

## From CentOS-Admin

```bash
ssh -o ConnectTimeout=5 opsadmin@172.27.10.100
```

Expected: successful login with the configured key and named admin account.

## From Ubuntu-Client

```bash
ssh -o ConnectTimeout=5 opsadmin@172.27.30.100
```

Expected: connection blocked under the intended policy.

## On Ubuntu-Workload

```bash
sudo sshd -t
sudo systemctl status ssh --no-pager
sudo ss -lntp | grep ':22'
sudo ufw status numbered
```

## Record actual result

Include client source IP, destination IP, authentication method, error text, and screenshot filename. A failed connection should be diagnosed rather than automatically counted as a successful firewall denial; confirm the service and route are otherwise healthy.
