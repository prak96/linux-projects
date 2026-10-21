# Network configuration

## Confirm current state

```bash
ip -br addr
ip route
ip route get 172.27.10.101
ip route get 172.27.30.201
```

Expected WEB-SRV01 addressing in this lab:

- `ens33`: `172.27.10.100/24` — management
- `ens37`: `172.27.30.100/24` — DMZ/web
- NAT interface: DHCP address on `192.168.232.0/24` (confirm interface name and gateway)

## For Ubuntu

### Netplan pattern

This is a pattern, not a drop-in configuration. Replace interface names and gateway/DNS values with the actual values in your VM.

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 172.27.10.100/24
    ens37:
      dhcp4: false
      addresses:
        - 172.27.30.100/24
    ens38:
      dhcp4: true
```

Do not add a static gateway under `ens38` if DHCP already supplies the correct gateway. Do not configure default gateways on the private interfaces unless you have deliberately designed policy-based routing.

### Apply safely

```bash
sudo cp /etc/netplan/<actual-file>.yaml /etc/netplan/<actual-file>.yaml.bak
sudo netplan generate
sudo netplan try
sudo netplan apply
```

If `netplan try` reports an error, fix the YAML and retry. Maintain correct YAML indentation.


## For CentOS

### Inside the ‘ifcfg-<nic-name>’ File pattern

This is a pattern, not a drop-in configuration. Replace interface names and gateway/DNS values with the actual values in your VM.

```bash
TYPE=Ethernet
BOOTPROTO=static
NAME=ens33		##(based on your nic name)
DEVICE=ens33		##(based on your nic name)
ONBOOT=yes
IPADDR=192.168.1.50         # <-- Set an unused static IP in your subnet
NETMASK=255.255.255.0
GATEWAY=192.168.1.1          # <-- Your router IP (NAT-enabled)
DNS1=8.8.8.8
DNS2=1.1.1.1            # <-- DNS Servers

```


## Troubleshooting checklist

- Is the IP in the intended subnet? A typo such as `192.168.10.101` instead of `172.27.10.101` breaks the plan.
- Is Hypervisor's local DHCP service enabled if DHCP is required?
- Does the VM's virtual NIC connect to the correct custom network?
- Is the expected gateway configured at the Hypervisor host/virtual-network layer?
- Is the default route pointing to the NAT interface?
- Does `ip route get <destination>` show the expected interface/source?
- Can the destination be reached before testing SSH or HTTP?

See [`../industry-level-problems/industry-problem-1/network-config-failure.md`](../industry-level-problems/industry-problem-1/network-config-failure.md).
