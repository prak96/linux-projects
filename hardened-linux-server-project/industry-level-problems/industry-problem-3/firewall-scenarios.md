# Industry problem 3: firewall scenarios and rule behavior

## Target behavior

| Source | Service on WEB-SRV01 | Expected |
|--------|----------------------|----------|
| `172.27.10.0/24` | TCP/22 | Allow |
| `172.27.30.0/24` | TCP/80 | Allow |
| `172.27.30.0/24` | TCP/443 | Allow only after TLS is configured |
| `172.27.30.0/24` | TCP/22 | Deny |
| Other inbound sources | Protected services | Deny |

## Failure scenario A: enabling UFW interrupts SSH

Before enabling UFW, check the intended management source and create the scoped allow rule. Keep console access. Confirm `sudo ufw status verbose` and test from the management client before ending the session.


## Failure scenario B: a specific allow exists but SSH is still reachable from everywhere

The project tested a specific allow alongside `22/tcp ALLOW IN Anywhere`. The broad allow still permits other sources. A subnet-specific rule does not revoke an independent broad allow.

```bash
sudo ufw status numbered
sudo ufw delete <current-rule-number>
sudo ufw status numbered
```

Re-check numbering after each deletion. Prefer removing unnecessary broad allows over layering confusing allow/deny entries. UFW is not safely understood as a universal, simple first-match ACL list; rule type and generated backend chains matter.

## Failure scenario C: wrong source address in a deny rule

If a rule was created for the wrong IP, inspect the current rule list, delete the incorrect entry, add the corrected rule, and verify again. UFW does not edit the old rule in place.

## Failure scenario D: firewall rule looks correct but connection fails

Check all layers:

```bash
ip -br addr
ip route
ip route get <destination-IP>
sudo ss -lntp
sudo ufw status verbose
sudo journalctl -k --no-pager | grep -i UFW
```

A firewall rule cannot start a stopped service, create a route, correct a wrong IP, or configure TLS.

## Safer implementation

After verifying interface names:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed
sudo ufw allow in on ens33 from 172.27.10.0/24 to any port 22 proto tcp
sudo ufw allow in on ens37 from 172.27.30.0/24 to any port 80 proto tcp
```

Add 443 only after the web server is configured to listen with TLS. Remove any broad `ALLOW Anywhere` rule that violates the policy. Validate from authorized and unauthorized source systems.

## Lockout recovery

Use the VMware console to inspect `ufw status numbered` and correct the rule set. Do not rely on an existing SSH session surviving a ruleset change. A separate break-glass admin account is useful only if its credentials and access path are managed securely; it does not replace hypervisor console access.
