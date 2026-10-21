# Screenshot and evidence checklist

Add genuine screenshots from your own lab. Keep each image focused on one claim and use a descriptive filename.

Suggested evidence:
- `01-vmware-network-adapters.png` — virtual NICs attached to the intended networks.
- `02-web-server-addresses.png` — `ip -br addr` showing management, DMZ, and NAT interfaces.
- `03-web-server-routes.png` — `ip route` and a relevant `ip route get`.
- `04-ssh-config-validation.png` — successful `sshd -t` and service status.
- `05-ssh-management-pass.png` — SSH from ADMIN-SRV01.
- `06-ssh-dmz-denied.png` — SSH failure from TEST-SRV01 with source IP visible.
- `07-apache-config-and-listener.png` — `apache2ctl configtest`, service state, and port 80.
- `08-calculator-page.png` — browser view of the working calculator.
- `09-ufw-numbered-rules.png` — final rule list with no unintended broad allow.
- `10-http-test-pass.png` — `curl -I` from TEST-SRV01.
- `11-apparmor-status.png` — actual `aa-status` output.
- `12-update-status.png` — update timer/service and relevant logs.

Before committing:
- Redact private keys, tokens, passwords, email addresses, and unrelated host details.
- Confirm screenshot labels and IPs match the written documentation.
- Do not fabricate PASS output. If a test is not complete, label it `PENDING`.
