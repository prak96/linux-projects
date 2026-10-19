# Test 5 — Hardening and patch posture

## SSH baseline

```bash
sudo sshd -T | grep -Ei 'pubkeyauthentication|passwordauthentication|permitrootlogin'
```

Confirm the effective settings, not just a single line in the file.

## AppArmor

```bash
sudo aa-status
sudo journalctl -k --no-pager | grep -i apparmor
```

Record actual enforcement state and any relevant denials.

## Ubuntu updates

```bash
dpkg -l unattended-upgrades
systemctl status unattended-upgrades --no-pager
sudo unattended-upgrade --dry-run --debug
```

## CentOS/RHEL-family updates

```bash
cat /etc/centos-release
rpm -q dnf-automatic
systemctl list-timers dnf-automatic.timer
sudo dnf upgrade --security --assumeno
```

Do not claim patch automation is operational solely because a package is installed. Capture timer/service state, configuration, and logs. Avoid applying unattended updates to production without change approval.
