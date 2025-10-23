#!/bin/sh
set -e

CONF_DIR="/etc/nginx/conf.d"
CERT_PATH="/etc/letsencrypt/live"

DOMAINS=$(grep -Eho 'server_name[[:space:]]+[^;]+' "$CONF_DIR"/*.conf \
  | sed -E 's/server_name[[:space:]]+//' \
  | tr -s ' ' '\n' \
  | sort -u)

if [ -z "$DOMAINS" ]; then
  exit 1
fi

for DOMAIN in $DOMAINS; do
  if [ ! -f "$CERT_PATH/$DOMAIN/fullchain.pem" ]; then
    certbot certonly --standalone --non-interactive --agree-tos --email "$CERTBOT_EMAIL" -d "$DOMAIN" || true
  else
    certbot renew --quiet
  fi
done
