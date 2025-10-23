# Nginx + Certbot (Alpine-based)
A minimal, production-ready Docker image combining **Nginx (Alpine)** and **Certbot** with automatic SSL certificate management.

**Served in:** [Docker Hub](https://hub.docker.com/r/mohsensamiei/nginx-certbot)

## This image automatically handles:
* HTTP → HTTPS redirection
* Let's Encrypt certificate issuance using **webroot**
* Auto-renewal of certificates via cron jobs
* Automatic Nginx reload after certificate renewal
* Separation of user configs and Certbot challenge configs (to prevent accidental interference)

## Features:
* Based on lightweight `nginx:alpine`
* Certificates stored in `/etc/letsencrypt`
* Configs loaded from `/etc/nginx/conf.d/*.conf`
* Challenge configs isolated in `/etc/nginx/default-conf.d/certbot.conf`
* Runs `nginx` and `crond` together for continuous certificate maintenance

## Environment Variables:
* `CERTBOT_EMAIL`: The email address used for Let's Encrypt registration and renewal notices
* `CERTBOT_RENEW`: Schedule expression for auto-renewal (e.g., `0 3 * * *`)

## Volumes:
* `/etc/letsencrypt`: Certificates and keys
* `/var/log/letsencrypt`: Letsencrypt challenges logs
* `/etc/nginx/conf.d`: Your custom Nginx configurations

## Example of docker run:
``` bash
docker run -d \
  --name nginx-certbot \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  mohsensamiei/nginx-certbot:latest
```

## Example docker-compose.yml:

``` yaml
services:
  nginx-certbot:
    image: mohsensamiei/nginx-certbot:latest
    environment:
      - CERTBOT_EMAIL=admin@example.com
      - CERTBOT_RENEW=0 3 * * *
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./conf.d:/etc/nginx/conf.d:ro
      - letsencrypt-etc:/etc/letsencrypt
volumes:
  letsencrypt-etc:
```

## Example nginx configuration:
``` nginx
server {
  listen 443 ssl;
  server_name _DOMAIN_NAME_;
  ssl_certificate /etc/letsencrypt/live/_DOMAIN_NAME_/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/_DOMAIN_NAME_/privkey.pem;
  location / {
    return 200 "SSL OK for $host\n";
    add_header Content-Type text/plain;
  }
}
```

## How it works:

On startup, the container scans user Nginx configs for domain names.

Certbot automatically issues certificates for each domain using webroot validation.

A cron job periodically runs `certbot renew` and reloads Nginx if renewal occurs.

HTTP requests are redirected to HTTPS while `.well-known/acme-challenge/` remains accessible for certificate validation.