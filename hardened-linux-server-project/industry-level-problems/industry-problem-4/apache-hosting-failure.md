# Industry problem 4: Apache hosting failure

## Incident pattern

The project included an Apache website that was unavailable due to firewall/service/configuration issues and explored serving a `.cshtml` file.

## Key distinction: static versus server-rendered content

Apache can serve static HTML, CSS, JavaScript, and other files. Renaming an ASP.NET Razor `.cshtml` file to `.html` does not make it execute as ASP.NET. A `.cshtml` page requires an ASP.NET application/runtime and appropriate hosting/reverse-proxy configuration. For this lab, the HTML/JavaScript calculator is a suitable static demonstration.

## Troubleshooting sequence

```bash
sudo apache2ctl configtest
sudo systemctl status apache2 --no-pager
sudo journalctl -u apache2 --no-pager -n 50
sudo tail -n 50 /var/log/apache2/error.log
sudo ss -lntp | grep -E ':(80|443)\b'
curl -I http://127.0.0.1/
curl -I http://172.27.30.100/
sudo ufw status verbose
```

Check:

1. Apache configuration syntax.
2. Service state.
3. Listener on the expected port.
4. Document root and file permissions.
5. Firewall policy.
6. Route/source path from the test client.
7. AppArmor denials, if logs indicate them.

## Change control

Back up the current site/configuration, validate before reload, and use logs to diagnose a 403/404/connection timeout rather than changing permissions indiscriminately. Do not use `chmod 777` as a generic fix.
