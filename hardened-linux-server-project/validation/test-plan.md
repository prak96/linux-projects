# Validation plan

Record actual outcomes and timestamps when running tests. The expected results below describe the intended design, not pre-verified proof for every environment.

| ID | Test | Source | Expected result |
|---|---|---|---|
| T01 | Address and route inventory | All VMs | Correct addresses, connected routes, one intended default route |
| T02 | SSH from management subnet | ADMIN-SRV01 | Pass |
| T03 | SSH from DMZ/test subnet | TEST-SRV01 | Fail |
| T04 | HTTP request to web IP | TEST-SRV01 | Pass after Apache and UFW are configured |
| T05 | HTTP request from management path | ADMIN-SRV01 | Denied under the intended policy |
| T06 | HTTPS handshake | TEST-SRV01 | Not complete in the source project; mark pending until TLS is configured |
| T07 | SSH config syntax | WEB-SRV01 | `sshd -t` returns no error |
| T08 | Apache config syntax | WEB-SRV01 | `apache2ctl configtest` reports `Syntax OK` |
| T09 | UFW policy review | WEB-SRV01 | No unintended broad inbound allow |
| T10 | AppArmor status | WEB-SRV01 | Record actual profile/mode and relevant logs |
| T11 | Patch mechanism | Ubuntu/CentOS test hosts | Correct OS-specific tooling and logs confirmed |

For every test, record: date/time, source host/IP, destination IP/port, exact command, observed output, PASS/FAIL, diagnosis, and evidence filename.
