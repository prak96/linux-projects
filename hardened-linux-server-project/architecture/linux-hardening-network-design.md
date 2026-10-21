# Network design

## Address plan

| Segment | Subnet | Purpose | Policy |
|---|---|---|---|
| Management | `172.27.10.0/24`   | Admin-to-server management       | SSH/TCP 22 only |
| DMZ / test | `172.27.30.0/24`   | Website access and validation    | HTTP 80; HTTPS 443 only when TLS is configured |
| NAT        | `192.168.232.0/24` | Outbound package/internet access | Use the gateway actually provided by VMware DHCP |


Use `ip -br addr` to confirm interface names. The Word notes use both `ens38` and other interface labels in examples; do not blindly paste a sample YAML file.

## Routing principles

- The management and DMZ interfaces need connected routes for their directly attached subnets.
- Normally, only the NAT/outbound interface receives the default gateway in this lab.
- Do not add a default gateway to every NIC. Multiple default routes can cause asymmetric paths or unexpected source/interface selection.
- DHCP may already provide the NAT gateway. Confirm using `ip route`; do not guess the gateway address.
- Use `ip route get <destination>` to see the chosen egress interface and source address.

## Netplan safety workflow

For Ubuntu:
```bash
ip -br addr
ip route
sudo cp /etc/netplan/00-installer-config.yaml \
  /etc/netplan/00-installer-config.yaml.bak
sudo netplan generate
sudo netplan try
# Accept only if connectivity remains healthy.
sudo netplan apply
```

Use the actual Netplan filename on the VM. Some systems use `50-cloud-init.yaml` or another file. Do not edit generated configuration without checking its source/ownership.


For CentOS:
```bash
ip -br addr
ip route
sudo cp /etc/sysconfig/network-scripts/ \
  /etc/sysconfig/network-scripts/ifcfg-ens161.bak

sudo cp /etc/sysconfig/network-scripts/ \
  /etc/sysconfig/network-scripts/ifcfg-ens133.bak
sudo systemctl status networking.service
sudo systemctl restart networking.service

<Restart if DO NOT WORKS!!!>
```



## Firewall design caveat

An IP address is not a VLAN, and a firewall rule is not a substitute for verifying routing. Test the intended source from ADMIN-SRV01 and TEST-SRV01 separately. Confirm both destination IPs and the path selected by the client.
