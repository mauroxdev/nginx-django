#!/bin/sh

set -e

if [ "${CLOUDFLARE_ONLY}" = "true" ] ; then
    /update_cloudflare_ips.sh
fi

if [ "${CERTBOT_ENABLED}" = "true" ] ; then
    certbot certonly --webroot -w /var/www/certbot -d ${NGINX_SERVER_NAME} --email ${CERTBOT_EMAIL} --agree-tos --no-eff-email
fi

export DOLLAR='$' 
envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"
