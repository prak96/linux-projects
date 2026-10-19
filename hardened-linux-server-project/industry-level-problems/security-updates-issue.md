# Challenge: automatic security updates unavailable on CentOS

## Symptom

The project encountered a missing service/unit when trying to use `unattended-upgrades` on CentOS.

## Root cause

`unattended-upgrades` is primarily associated with Debian/Ubuntu. CentOS/RHEL-family systems commonly use `dnf-automatic` or, on older releases, `yum-cron`.

## Diagnosis and resolution

```bash
cat /etc/centos-release
rpm -q dnf-automatic
systemctl list-unit-files | grep -E 'dnf-automatic|yum-cron'
```

If approved and repositories are working:

```bash
sudo dnf install dnf-automatic
sudoedit /etc/dnf/automatic.conf
```

Review `upgrade_type`, `download_updates`, and `apply_updates`, then check the timer/service and logs. Use `dnf upgrade --security --assumeno` to preview a package transaction without accepting it.

## Operational lesson

Select the patching mechanism for the actual OS version. A missing unit is not fixed by repeatedly restarting it. Validate package availability, repository health, configuration, timer state, and logs.
