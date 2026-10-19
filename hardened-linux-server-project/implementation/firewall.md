# UFW firewall policy

## Desired policy

- Default deny inbound.
- Default allow outbound unless the environment requires a stricter egress policy.
- Permit SSH only from the management subnet.
- Permit HTTP from the DMZ/test subnet.
- Permit HTTPS only when TLS is configured and required.
- Deny other unsolicited inbound access.

## Inspect before changing

```bash
ip -br addr
ip route
sudo ufw status numbered
sudo ufw status verbose
sudo ss -lntp
```

If connected over SSH, ensure console access and the correct allow rule are available before enabling UFW.

## Safer clean policy sequence

The exact commands depend on the current rule set. Review numbered rules and remove stale/broad allows rather than stacking contradictory rules.

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed

# Allow management subnet to SSH:
sudo ufw allow in on ens33 from 172.27.10.0/24 to any port 22 proto tcp

# Allow DMZ/test subnet to HTTP:
sudo ufw allow in on ens37 from 172.27.30.0/24 to any port 80 proto tcp

# Add only after TLS is configured:
sudo ufw allow in on ens37 from 172.27.30.0/24 to any port 443 proto tcp
```

Confirm interface names and current policy before running. Then inspect the active rules and remove any broad rule such as `22/tcp ALLOW IN Anywhere` if it is not intended:

```bash
sudo ufw status numbered
sudo ufw delete <current-rule-number>
sudo ufw status numbered
```

Rule numbers change after deletions. Recheck the list before each deletion.

## Why broad rules matter

A source-specific allow rule does not cancel an independent broad allow rule. For example, allowing `172.27.10.0/24` to SSH while retaining `22/tcp ALLOW IN Anywhere` still leaves SSH open to other sources. Prefer removing the broad rule and verifying from both permitted and denied clients. Do not assume UFW behaves like a simple first-match ACL in every rule path.

## Verify

From SERVER - "centos-admin":

```bash
ssh hrx@172.27.10.100
```

From SERVER - "ubuntu-client":

```bash
curl -I --connect-timeout 5 http://172.27.30.100/
ssh -o ConnectTimeout=5 opsadmin@172.27.30.100
```

Expected: management SSH works; DMZ HTTP works; DMZ SSH fails. A failed test can also be caused by routing, a stopped service, or wrong source IP, so correlate with server-side checks.

## Logs

```bash
sudo ufw logging on
sudo journalctl -k --no-pager | grep -i UFW
```

See [Firewall scenarios](../industry-level-problems/industry-problem-3/firewall-scenarios.md).
