# SSH hardening

## Recommended access model

Use a named administrative account with `sudo`, public-key authentication, and `PermitRootLogin no`. Avoid routine direct root SSH. Keep a console recovery path before modifying authentication settings.

## Install and inspect OpenSSH

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
sudo systemctl status ssh --no-pager
sudo ss -lntp | grep ':22'
```

CentOS/RHEL generally uses `sshd` as the service name.

## Create an administrative user

```bash
sudo adduser opsadmin
sudo usermod -aG sudo opsadmin
id opsadmin
```

On RHEL-like systems, the administrative group is commonly `wheel`; confirm the sudoers policy before assuming membership grants access.

## Configure key-based authentication

On the client, create a key pair (example):

```bash
ssh-keygen -t ed25519 -a 64
ssh-copy-id opsadmin@172.27.10.100
```

If `ssh-copy-id` is unavailable, install the public key in the user's `~/.ssh/authorized_keys` using a trusted console/initial login. Never copy the private key to the server.

Typical permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Review SSH settings

Back up first:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudoedit /etc/ssh/sshd_config
```

Recommended baseline (check for conflicting directives and included files):

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

Do not blindly add duplicate directives; OpenSSH may use the first obtained value depending on configuration context. Validate effective settings:

```bash
sudo sshd -t
sudo sshd -T | grep -Ei 'pubkeyauthentication|passwordauthentication|permitrootlogin'
```

Only after validation:

```bash
sudo systemctl reload ssh
sudo systemctl status ssh --no-pager
```

Keep the current session open and test a second login before closing it.

## Troubleshoot connection failure

```bash
sudo sshd -t
sudo systemctl status ssh --no-pager
sudo journalctl -u ssh --no-pager -n 50
sudo ss -lntp | grep ':22'
sudo ufw status numbered
ip route
```

The project intentionally encountered SSH restart failures and firewall lockouts. See the [SSH access failure case](../industry-level-problems/industry-problem-2/ssh-access-failure.md).
