ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/nginx:nginx-1-19-5-alpine

EXPOSE 8000
CMD ["/bin/sh", "-c", "sed -i 's/listen  .*/listen 8000;/g' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]