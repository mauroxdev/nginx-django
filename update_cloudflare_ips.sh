#!/bin/sh

set -e

wget https://www.cloudflare.com/ips-v4 -O /tmp/cf_ips_v4
wget https://www.cloudflare.com/ips-v6 -O /tmp/cf_ips_v6

{ \
    echo "# Cloudflare IP ranges"; \
    echo ""; \
    while read -r ip; do echo "set_real_ip_from $ip;"; done < /tmp/cf_ips_v4; \
    while read -r ip; do echo "set_real_ip_from $ip;"; done < /tmp/cf_ips_v6; \
    echo ""; \
    echo "real_ip_header CF-Connecting-IP;"; \
} > /etc/nginx/cloudflare.conf

