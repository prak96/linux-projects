# Hardened Linux Server Project

A production-inspired Linux infrastructure lab built with **Ubuntu Server 24.04**, Virtualization Platform, Apache2, OpenSSH, UFW and automated security-update tooling. The project focuses on secure administration, network segmentation, controlled web access, recovery planning, and evidence-based troubleshooting.

> **Lab, not a production deployment.** This repository documents a learning environment and the observed troubleshooting journey. HTTPS was planned, but the project notes state that the final website validation remained on HTTP/80. Do not interpret port 443 firewall rules as proof that TLS was configured.

## Project goals

- Separate management access from web/application access using dedicated virtual networks.
- Restrict SSH to the management network and HTTP/HTTPS to the test/application network.
- Harden SSH using key authentication and avoid routine direct root SSH.
- Deploy an Apache-hosted HTML calculator page.
- Inspect AppArmor and automatic security-update controls.
- Reproduce realistic failures, diagnose them systematically, and document recovery.
- Validate both allowed and denied traffic from the correct client systems.

## Infrastructure flow chart


See [`architecture/architecture-diagram.png`](architecture/architecture-diagram.png) and [`architecture/network-topology.png`](architecture/network-topology.png).

## Lab inventory

| System | Role | Relevant address / interface |
|---|---|---|
| WEB-SRV01 (`web-workload`) | Hardened web server | Management `172.27.10.100` (`ens33`); DMZ `172.27.30.100` (`ens37`); NAT DHCP interface may be `ens38` |
| ADMIN-SRV01 (`centos-admin`) | Administrative client | `172.27.10.101` on management network |
| TEST-SRV01 (`ubuntu-client`) | Application/security test client | `172.27.30.201` on DMZ/test network |
| VMware NAT | Outbound connectivity | `192.168.232.0/24` (actual gateway must be confirmed on the host/lab) |

Interface names and addresses are lab-specific. Always confirm with `ip -br address` and `ip route` before applying commands.

## Intended traffic policy

| Source | Destination service | Expected result |
|---|---|---|
| Management subnet `172.27.10.0/24` | SSH/TCP 22 on WEB-SRV01 | Allow |
| DMZ/test subnet `172.27.30.0/24` | HTTP/TCP 80 on WEB-SRV01 | Allow |
| DMZ/test subnet `172.27.30.0/24` | HTTPS/TCP 443 on WEB-SRV01 | Allow only after TLS is configured and verified |
| DMZ/test subnet | SSH/TCP 22 | Deny |
| Management subnet | HTTP/HTTPS through the management path | Deny under the intended policy |
| Other inbound sources | Protected services | Deny unless explicitly required |

**Important:** UFW rules alone do not prove that traffic uses a particular interface or route. Validate the source address, destination address, route, interface, listening socket, and actual remote result. Do not rely on “allow then deny” rules to express a clean policy when broad allow rules already exist.


## Implementation overview

1. Build the three VMs and virtual networks.
2. Configure the WEB-SRV01 interfaces and confirm routing.
3. Create an administrative user and validate `sudo`.
4. Configure SSH keys; validate `sshd` before restarting.
5. Install Apache2 and deploy the static HTML calculator.
6. Apply UFW default-deny inbound policy and narrowly scoped service rules.
7. Review AppArmor state and automatic security updates.
8. Run positive and negative connectivity tests from the right source hosts.
9. Capture command output/screenshots and document failures and recovery.

Start with [`implementation/installation.md`](implementation/installation.md), then follow the implementation files in order.

## Troubleshooting method

Use a layered sequence instead of changing multiple things at once:

1. **Addressing:** `ip -br addr`
2. **Routing:** `ip route` and `ip route get <destination>`
3. **Service state:** `systemctl status <service>`
4. **Configuration syntax:** `sshd -t`, `apache2ctl configtest`, `netplan generate`
5. **Listening sockets:** `sudo ss -lntp`
6. **Host firewall:** `sudo ufw status numbered` / `sudo ufw status verbose`
7. **Logs:** `journalctl -u <service> --no-pager -n 50`
8. **Remote proof:** `ssh`, `curl -I`, and optionally `nmap` from the intended client

## Security and operational guardrails

- Keep a Hypervisor console or other out-of-band recovery path available before changing networking, SSH, or firewall rules.
- Back up configuration files before editing them.
- Never commit private SSH keys, passwords, tokens, real hostnames, or sensitive logs.
- Avoid unrestricted `ufw allow 22/tcp` except as a temporary, controlled recovery measure; remove it after confirming scoped access.
- Prefer a normal admin account with `sudo`; keep direct root SSH disabled.
- Use `visudo` for sudo policy changes.
- Validate configuration before restarting a service.
- The lab's HTTP page is a demonstration, not a production application. Do not expose it to the public internet.

## Evidence and honesty

Screenshots should show real output from your own lab. The repository includes a screenshot checklist, not fabricated proof. Replace any example/expected outcomes with your actual result and date before publishing.

## Skills demonstrated

Linux server administration • Hypervisor Platform networking • Netplan • OpenSSH • sudoers and groups • Apache2 • UFW • unattended security updates • packet-path troubleshooting • configuration validation • recovery planning • test documentation.

