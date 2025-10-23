#!/bin/sh
certbot renew --webroot -w /var/www/certbot --deploy-hook "nginx -s reload" >> /var/log/letsencrypt/renew.log 2>&1