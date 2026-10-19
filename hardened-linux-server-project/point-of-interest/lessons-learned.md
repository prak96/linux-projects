# Lessons learned

## What the project demonstrates

- A server may have multiple NICs, but default-route design still matters.
- A wrong IP/subnet or VMware virtual-network setting can look like an SSH/service problem.
- `sshd -t` and `apache2ctl configtest` should be run before restarting services.
- A running service is not sufficient: the listener, route, firewall, and client path must also be correct.
- Broad firewall allows can undermine a more specific intended policy.
- UFW rule numbering changes after deletion; inspect before every numbered deletion.
- Ubuntu and CentOS/RHEL use different group and patching conventions.
- Recovery access and snapshots should be planned before restrictive changes.
- A `.cshtml` file is not executable server-side merely because it is renamed to `.html`.
- Opening TCP/443 in a firewall does not configure TLS.

## Improvements for a next iteration

- Use a single source of truth for IP addresses, interfaces, and host roles.
- Store sanitized command outputs as test evidence.
- Add a repeatable test matrix for allowed and denied flows.
- Configure TLS with a proper certificate and verify the handshake before claiming HTTPS.
- Add configuration management or automation only after the manual baseline is stable.
- Track changes with timestamps and rollback notes.

## What not to claim

Do not claim production deployment, vulnerability scanning, TLS enablement, automated compliance, or successful tests unless the repository includes evidence. Distinguish “planned,” “configured,” and “verified.”
