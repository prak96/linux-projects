# Snapshot and recovery strategy

The project reused existing lab VMs and encountered difficulty cleaning up prior configurations. This is a useful reason to plan rollback before making changes.

## Recommended checkpoint sequence

1. **Baseline snapshot:** OS booted, networking recorded, no project changes.
2. **Network checkpoint:** IP addresses and routes validated.
3. **Access checkpoint:** named admin user and SSH access tested.
4. **Web checkpoint:** Apache site validated locally.
5. **Firewall checkpoint:** scoped rules tested from both permitted and denied clients.

## Before taking a snapshot

- Record the date, VM name, and purpose.
- Ensure there is enough datastore/host storage.
- Avoid treating a long-lived snapshot as a backup.
- Keep a separate backup of critical configuration files.
- For a multi-VM project, document which snapshots belong to the same test state.

## Rollback

Use the VMware console to restore a known-good lab state when a network/firewall change removes remote access. After rollback, re-check IPs, routes, service state, and firewall rules before resuming.

Snapshots are for lab recovery; production backup and disaster-recovery design require independent, tested backups.
