FROM nginx:alpine3.22

RUN apk --no-cache add openssl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY nginx.conf /etc/nginx/nginx.conf.template
COPY templates /etc/nginx/templates

# Remove default conf
RUN rm -f /etc/nginx/conf.d/default.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]