# Permissions model

## Administrative access

Use named accounts and group-based privilege assignment rather than sharing the root password. Ubuntu commonly uses the `sudo` group; CentOS/RHEL commonly uses `wheel` if enabled in sudoers.

```bash
id <username>
sudo -l -U <username>
sudo visudo -c
```

## SSH key files

- Private key: client-side only; protect with a passphrase and restrictive permissions.
- Public key: placed in the target account's `~/.ssh/authorized_keys`.
- `~/.ssh`: typically mode `700`.
- `authorized_keys`: typically mode `600`.

## Apache content

Static content should be readable by the Apache worker, but not world-writable. Do not use `chmod 777` as a troubleshooting shortcut. Inspect ownership and effective directory permissions:

```bash
namei -l /var/www/html/index.html
ls -l /var/www/html/
```

## Principle of least privilege

Give each account and network path only the access needed for its role. Validate the actual effective configuration; membership in a group is not proof that sudoers grants that group access.
