#!/bin/sh

set -e

BASE_CONF="/etc/nginx/nginx.conf"

if [ -f "${BASE_CONF}" ]; then
    rm -f "${BASE_CONF}"
fi

case "$NGINX_CONFIG" in
  prod)
    cp /etc/nginx/nginx-prod.conf "${BASE_CONF}"
    ;;
  test)
    cp /etc/nginx/nginx-test.conf "${BASE_CONF}"
    ;;
  *)
    cp /etc/nginx/nginx-prod.conf "${BASE_CONF}"
    ;;
esac

mkdir -p /run/nginx /var/log/nginx
chown -R nginx:nginx /run/nginx /var/log/nginx

su-exec nginx nginx -g "daemon off;"
