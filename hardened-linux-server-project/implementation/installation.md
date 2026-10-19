# Installation and lab preparation

## Prerequisites

- Three Linux VMs.
- Ubuntu Server 24.04 for WEB Server (`web-workload`) & TEST Server (`ubuntu-client`) with CentOS-8.3.2011 for ADMIN Server (`centos-admin`) as described in the project plan. A CentOS admin VM for cross-distribution testing.
- Console access to WEB Server (`web-workload`) before enabling UFW or changing SSH.
- One management virtual network, one DMZ/test virtual network, and a NAT network.
- Enough disk space for OS updates and Apache packages.

## VM roles

| VM | Purpose |
|---|---|
| WEB Server (`web-workload`)   | Apache2, SSH, UFW |
| ADMIN Server (`centos-admin`) | SSH administration from management network |
| TEST Server (`ubuntu-client`) | `curl`, optional `nmap`, HTTP & HTTPS tests |

## Build sequence

1. Create the virtual networks in your infra or hypervisors.
2. Attach WEB Server (`web-workload`) to management, DMZ/test, and NAT networks.
3. Attach ADMIN Server (`centos-admin`) to management and NAT network.
4. Attach TEST Server (`ubuntu-client`) to DMZ/test and NAT network.
5. Boot each VM and record its actual NIC names.
6. Configure addresses, routes, and DNS. Avoid duplicate addresses.
7. Take a baseline VM snapshot before changing SSH/firewall settings.
8. Update packages and install tools as needed.

## Initial checks

```bash
hostnamectl
cat /etc/os-release
ip -br addr
ip route
systemctl --failed
```

## Install web and diagnostic packages on WEB-SRV01

```bash
sudo apt update
sudo apt install apache2 openssh-server ufw curl -y
sudo systemctl enable --now apache2
sudo systemctl enable --now ssh
```

On Ubuntu, the service is normally called `ssh`; on CentOS/RHEL, it is normally `sshd`. Verify the name for the distribution before running commands.

## Before you proceed

- Confirm console access works.
- Confirm you know the VM's current IP and default route.
- Keep a copy of the original Netplan, SSH, Apache, and UFW settings.
- Do not enable a restrictive firewall until the intended SSH allow rule is in place and a console recovery path is available.
