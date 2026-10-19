# Challenge: `sudo` fails after group membership changes

## Symptoms

- `sudo: user is not in the sudoers file`
- User belongs to a group but cannot elevate privileges.
- `su` fails even though `sudo` works, or vice versa.

## Diagnosis

```bash
id <username>
groups <username>
sudo -l -U <username>
sudo grep -E '^(%sudo|%wheel)' /etc/sudoers
sudo visudo -c
```

Group names and sudoers defaults differ by distribution:

- Ubuntu/Debian commonly grants sudo via the `sudo` group.
- RHEL/CentOS commonly uses `wheel`.

Adding a user to `wheel` on Ubuntu does not automatically grant privileges unless the sudoers policy enables that group.

## Remediation

Ubuntu/Debian:

```bash
sudo usermod -aG sudo <username>
```

RHEL/CentOS (if configured to use wheel):

```bash
sudo usermod -aG wheel <username>
```

Have the user start a fresh login session, then validate:

```bash
id
sudo -v
sudo -l
```

If the group rule is missing, use `sudo visudo` to edit policy safely. Never edit `/etc/sudoers` with an ordinary editor without syntax validation. Do not blindly uncomment a `wheel` rule on a system where that is not the intended policy.

## Root login is separate

`sudo` permission and `su` authentication are different. A locked root password can prevent `su` while `sudo` still works. Prefer `sudo` rather than enabling root login solely to make `su` work.
