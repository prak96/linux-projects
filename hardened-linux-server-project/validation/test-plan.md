# Validation plan

Record actual outcomes and timestamps when running tests. The expected results below describe the intended design, not pre-verified proof for every environment.

| ID | Test | Source | Expected result |
|----|------|--------|-----------------|
| T01 | Address and route inventory | All VMs | Correct addresses, connected routes, one intended default route |
| T02 | SSH from management subnet | CentOS-Admin | Pass |
| T03 | SSH from DMZ/test subnet | Ubuntu-Client | Fail |
| T04 | HTTP request to web IP | Ubuntu-Client | Pass after Apache and UFW are configured |
| T05 | HTTP request from management path | CentOS-Admin | Denied under the intended policy |
| T06 | HTTPS handshake | Ubuntu-Client | Not complete in the source project; mark pending until TLS is configured |
| T07 | SSH config syntax | Ubuntu-Client | `sshd -t` returns no error |
| T08 | Apache config syntax | Ubuntu-Client | `apache2ctl configtest` reports `Syntax OK` |
| T09 | UFW policy review | Ubuntu-Client | No unintended broad inbound allow |
| T10 | Patch mechanism | Ubuntu/CentOS test hosts | Correct OS-specific tooling and logs confirmed |

For every test, record: date/time, source host/IP, destination IP/port, exact command, observed output, PASS/FAIL, diagnosis, and evidence filename.
