# Test 4 — Apache application validation

## On Ubuntu-Workload

```bash
sudo apache2ctl configtest
sudo systemctl is-active apache2
sudo ss -lntp | grep ':80'
curl -I http://127.0.0.1/
curl -I http://172.27.30.100/
```


## From Ubuntu-Client

```bash
curl -v --connect-timeout 5 http://172.27.30.100/
```

Open the URL in a browser and test calculator addition, subtraction, multiplication, division, empty inputs, and division by zero.


## If it fails

Inspect Apache logs, document-root permissions, UFW & route selections. A static `.html` page works as static content; a `.cshtml` file is not automatically executed by Apache.


## Record actual status

- Config test:
- Service state:
- HTTP status:
- Calculator cases:
- Evidence filename:
