FROM nginx:alpine3.22

RUN apk --no-cache add openssl

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY templates /etc/nginx/templates

RUN mkdir -p /var/log/supervisor

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]