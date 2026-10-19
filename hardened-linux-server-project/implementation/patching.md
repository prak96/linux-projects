# Security updates and patch management

## Ubuntu

```bash
sudo apt update
apt list --upgradable
sudo apt upgrade
```

Ubuntu commonly uses `unattended-upgrades` for automated security updates.

```bash
dpkg -l unattended-upgrades
systemctl status unattended-upgrades --no-pager
sudo unattended-upgrade --dry-run --debug
sudo ls -l /var/log/unattended-upgrades/
sudo tail -n 50 /var/log/unattended-upgrades/unattended-upgrades.log
```

Check the actual package/service state; defaults can differ by image and installation choices.

## CentOS/RHEL-family systems

`unattended-upgrades` is not the standard mechanism on CentOS. Depending on version, use `dnf-automatic` or older `yum-cron`.

```bash
cat /etc/centos-release
rpm -q dnf-automatic
```

If approved for the lab and package repositories are available:

```bash
sudo dnf install dnf-automatic
sudoedit /etc/dnf/automatic.conf
```

Review the `[commands]` section. Setting `apply_updates = yes` enables automatic application when the configured service runs; `no` prevents that automatic installation. Inspect the timer/service and logs before claiming the automation works.

```bash
systemctl status dnf-automatic.timer --no-pager
systemctl list-timers dnf-automatic.timer
journalctl -u dnf-automatic.service --no-pager -n 50
```

A package transaction preview is:

```bash
sudo dnf upgrade --security --assumeno
```

This is not the same thing as a complete dry run of the automatic update service.

## Operational guardrails

- Test updates in a maintenance window.
- Review package changes and restart impact.
- Keep backups/snapshots and a recovery plan.
- Document update status and logs.
- Do not enable automatic installation on a production system without change control.
