#!/bin/sh
set -e

# This script generates the nginx configuration from templates
# and then executes the main container command.

TEMPLATE_DIR="/etc/nginx/templates"
CONFIG_DIR="/etc/nginx/conf.d"

# Set default values
export NGINX_SSL_ENABLED=${NGINX_SSL_ENABLED:-false}
export CLOUDFLARE_ONLY=${CLOUDFLARE_ONLY:-false}
export NGINX_USER=${NGINX_USER:-nginx}
export NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-1}
export NGINX_WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-256}

if [ -z "${NGINX_SERVER_NAME}" ]; then
    echo "Error: NGINX_SERVER_NAME environment variable must be set." >&2
    exit 1
fi

# Generate configs
envsubst '${NGINX_USER} ${NGINX_WORKER_PROCESSES} ${NGINX_WORKER_CONNECTIONS}' \
    < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
envsubst '${NGINX_SERVER_NAME}' \
    < "${TEMPLATE_DIR}/django-app.conf" > "${CONFIG_DIR}/django-app.conf"


if [ "$CLOUDFLARE_ONLY" = "true" ]; then
    curl -sL https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips_v4
    curl -sL https://www.cloudflare.com/ips-v6 -o /tmp/cf_ips_v6

    { \
        echo "# Cloudflare IP ranges"; \
        echo ""; \
        while read -r ip; do echo "set_real_ip_from $ip;"; done < /tmp/cf_ips_v4; \
        while read -r ip; do echo "set_real_ip_from $ip;"; done < /tmp/cf_ips_v6; \
        echo ""; \
        echo "real_ip_header CF-Connecting-IP;"; \
    } > "${CONFIG_DIR}/cloudflare.conf"
else
    # Create an empty file if not using Cloudflare
    touch "${CONFIG_DIR}/cloudflare.conf"
fi

CERT_PATH="/etc/nginx/certs/${NGINX_SERVER_NAME}.crt"
KEY_PATH="/etc/nginx/certs/${NGINX_SERVER_NAME}.key"

if [ ! -f "${CERT_PATH}" ] || [ ! -f "${KEY_PATH}" ]; then
    echo "SSL certificate not found. Generating self-signed certificate for ${NGINX_SERVER_NAME}..."
    mkdir -p /etc/nginx/certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${KEY_PATH}" \
        -out "${CERT_PATH}" \
        -subj "/CN=${NGINX_SERVER_NAME}"
    echo "Self-signed certificate generated."
else
    echo "Using existing SSL certificate."
fi

echo "Setting ownership of SSL certificates..."
chown -R "${NGINX_USER}":"${NGINX_USER}" /etc/nginx/certs
chown -R "${NGINX_USER}":"${NGINX_USER}" "${CONFIG_DIR}"

# Execute the main command
exec "$@"
