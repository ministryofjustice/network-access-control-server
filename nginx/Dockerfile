FROM nginx:1.25-alpine

EXPOSE 8000
CMD ["/bin/sh", "-c", "sed -i 's/listen  .*/listen 8000;/g' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
