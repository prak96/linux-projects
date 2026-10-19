# Industry problem 1: network configuration failure

## Incident

The expected static address was not applied and SSH connectivity failed. Later identified an incorrect address (`192.168.10.101` instead of the planned `172.27.10.101`) and Hypervisor virtual-network DHCP settings that were not fully configured.

## Investigation

```bash
ip -br addr
ip route
ip route get 172.27.10.100
```

At the Hypervisor layer, verify:

- The VM NIC is attached to the intended custom virtual network.
- The custom subnet matches the address plan.
- Hypervisor local DHCP is enabled only if DHCP is intended, and its range is correct.
- The host virtual adapter/gateway configuration matches the design.

## Recovery workflow

1. Use the Hypervisor console so remote access is not required.
2. Correct the subnet/address typo and check for duplicate IPs.
3. Confirm the Netplan file (for Ubuntu)/ifcfg File (for CentOS) and actual NIC names.
4. Back up the configuration.
5. Apply the Network Configurations.
6. Accept only after connectivity is verified; otherwise allow rollback and correct the file.
7. Verify routes and SSH from the management client.

## Multi-NIC lesson

In the lab, management (`172.27.10.0/24`) and DMZ (`172.27.30.0/24`) are private connected networks; NAT provides outbound access. Avoid configuring a default gateway on every NIC. If the NAT NIC uses DHCP, confirm its supplied gateway rather than adding a conflicting static gateway.

## Validation evidence

Capture `ip -br addr`, `ip route`, the relevant Netplan excerpt with no secrets, and a successful SSH test from ADMIN-SRV01.
