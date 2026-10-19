# Test 3 — UFW allowed and denied traffic

## Inspect policy

```bash
sudo ufw status numbered
sudo ufw status verbose
```

## From TEST-SRV01

```bash
curl -I --connect-timeout 5 http://172.27.30.100/
nmap -Pn -p 22,80,443 172.27.30.100
```

Run `nmap` only against your own lab hosts. If HTTPS is not configured, a closed/unlistening 443 result is not proof that UFW blocked it.

## Expected

- HTTP/80: reachable from DMZ/test network once Apache is running.
- SSH/22: not reachable from DMZ/test network.
- HTTPS/443: pending until TLS listener/certificate are configured.
- No broad SSH allow from `Anywhere` remains if the design is restricted.

## Record

Save the UFW rule listing and client-side output. Identify the actual source address used by the client; NAT or multiple NICs may cause a different source than expected.
