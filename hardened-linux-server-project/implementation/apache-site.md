# Apache2 website deployment

## Install and start Apache

```bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable --now apache2
sudo systemctl status apache2 --no-pager
sudo ss -lntp | grep -E ':(80|443)\b'
```

## Deploy the calculator page

The lab used a basic HTML/JavaScript calculator as a simple application endpoint. Place the static page in the configured document root, commonly `/var/www/html/index.html`.

The page should support addition, subtraction, multiplication, and division, reject missing inputs, and prevent division by zero. Keep application logic simple; the project's value is primarily infrastructure security and operations, not frontend development.

```bash
sudo cp /var/www/html/index.html /var/www/html/index.html.bak 2>/dev/null || true
sudoedit /var/www/html/index.html
sudo apache2ctl configtest
sudo systemctl reload apache2
curl -I http://127.0.0.1/
curl -I http://172.27.30.100/
```

`apache2ctl configtest` checks Apache configuration syntax. It does not guarantee that every request will succeed; also check logs and filesystem permissions.

## HTTP versus HTTPS

The final working validation was HTTP/80 and HTTPS was not completed. A firewall allow rule for 443 does **not** create a TLS listener or certificate.

To claim HTTPS support, configure a TLS virtual host and certificate, then verify:

```bash
sudo ss -lntp | grep ':443'
curl -vkI https://172.27.30.100/
```

Use a trusted certificate and DNS name for production. Do not describe the lab as HTTPS-enabled until the listener and TLS handshake are verified.

## Logs and failure triage

```bash
sudo apache2ctl configtest
sudo systemctl status apache2 --no-pager
sudo journalctl -u apache2 --no-pager -n 50
sudo tail -n 50 /var/log/apache2/error.log
sudo ss -lntp
sudo ufw status verbose
```

See [Apache hosting failure](../industry-level-problems/industry-problem-4/apache-hosting-failure.md).
