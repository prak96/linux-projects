# Industry problem 2: SSH access failure

## Incident

The project recorded an SSH daemon restart failure after editing `sshd_config`, and separate lockouts after firewall rules were tightened.

## Diagnose the daemon first

Ubuntu:

```bash
sudo sshd -t
sudo systemctl status ssh --no-pager
sudo journalctl -u ssh --no-pager -n 50
```

CentOS/RHEL:

```bash
sudo sshd -t
sudo systemctl status sshd --no-pager
sudo journalctl -u sshd --no-pager -n 50
```

`sshd -t` validates syntax and host keys/configuration before restart. Fix the reported line or conflicting directive, then validate again.

## Validate listener and network path

```bash
sudo ss -lntp | grep ':22'
ip route
sudo ufw status numbered
```

From the client, test the correct destination address and source network. A working management IP does not imply that the DMZ address should accept SSH.

## Safe recovery

- Keep the current SSH session open while changing SSH configuration.
- Maintain VMware console access.
- Back up `/etc/ssh/sshd_config`.
- Validate before reload/restart.
- Test a second session before closing the original.
- If UFW blocks access, use the console to inspect and correct the current rule set; do not permanently open SSH to anywhere as a shortcut.

## Hardening recommendation

Use a normal admin account with public-key authentication and `PermitRootLogin no`. The project experimented with root access to understand the behavior; NOT to carry that temporary test into production.
