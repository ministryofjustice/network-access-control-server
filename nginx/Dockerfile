FROM nginx:1.27.2-alpine

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache bash

EXPOSE 8000
CMD ["/bin/sh", "-c", "sed -i 's/listen  .*/listen 8000;/g' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]

