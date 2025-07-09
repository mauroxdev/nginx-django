#!/bin/sh
set -e

# This script generates the nginx configuration from templates
# and then executes the main container command.

TEMPLATE_DIR="/etc/nginx/templates"
CONFIG_DIR="/etc/nginx/conf.d"

# Set default values
export NGINX_SSL_ENABLED=${NGINX_SSL_ENABLED:-false}
export CLOUDFLARE_ONLY=${CLOUDFLARE_ONLY:-false}
export DOLLAR='$'

# Always process the main nginx config template
VARS_TO_SUBSTITUTE='${NGINX_USER} ${NGINX_WORKER_PROCESSES} ${NGINX_WORKER_CONNECTIONS} ${NGINX_SERVER_NAME}'
envsubst "$VARS_TO_SUBSTITUTE" < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Process common locations template
envsubst < "$TEMPLATE_DIR/locations.conf" > "$CONFIG_DIR/locations.conf"

# Handle conditional Cloudflare configuration
if [ "$CLOUDFLARE_ONLY" = "true" ]; then
    envsubst < "$TEMPLATE_DIR/cloudflare.conf" > "$CONFIG_DIR/cloudflare.conf"
else
    # Create an empty file if not enabled, so the include directive doesn't fail
    touch "$CONFIG_DIR/cloudflare.conf"
fi

# Handle conditional SSL configuration
if [ "$NGINX_SSL_ENABLED" = "true" ]; then
    # Create the HTTPS server config
    envsubst < "$TEMPLATE_DIR/https.conf" > "$CONFIG_DIR/https.conf"
    # Create the SSL settings config
    envsubst < "$TEMPLATE_DIR/ssl.conf" > "$CONFIG_DIR/ssl.conf"
    # Create the redirect rule for the HTTP server
    echo "return 301 https://\$server_name\$request_uri;" > "$CONFIG_DIR/ssl_redirect.conf"
else
    # Create empty files if not enabled
    touch "$CONFIG_DIR/https.conf"
    touch "$CONFIG_DIR/ssl.conf"
    touch "$CONFIG_DIR/ssl_redirect.conf"
fi

echo "Nginx configuration generated."

# Execute the command passed as arguments to this script
exec "$@"