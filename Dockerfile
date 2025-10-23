FROM nginx:1.29.2-alpine

RUN apk add --no-cache python3 py3-virtualenv dcron bash curl openssl ca-certificates
RUN python3 -m venv /opt/venv
RUN /opt/venv/bin/pip install --no-cache-dir certbot

RUN rm -f /etc/nginx/conf.d/default.conf
RUN mkdir -p /etc/nginx/default-conf.d
COPY certbot.conf /etc/nginx/default-conf.d/certbot.conf
COPY nginx.conf /etc/nginx/nginx.conf

COPY init.sh /usr/local/bin/init.sh
COPY renew.sh /usr/local/bin/renew.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/init.sh /usr/local/bin/renew.sh /entrypoint.sh

EXPOSE 80 443
VOLUME ["/etc/nginx/conf.d", "/etc/letsencrypt", "/var/log/letsencrypt"]

ENV PATH="/opt/venv/bin:$PATH"
ENTRYPOINT ["/entrypoint.sh"]
