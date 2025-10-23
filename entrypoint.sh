#!/bin/sh
set -e

mkdir -p /etc/letsencrypt /var/www/certbot /var/lib/letsencrypt /var/log/letsencrypt

/usr/local/bin/init.sh || true

echo "$CERTBOT_RENEW /usr/local/bin/renew.sh" >> /etc/crontabs/root
crond -f -l 2 &

exec nginx -g "daemon off;"
