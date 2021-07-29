ARG SHARED_SERVICES_ACCOUNT_ID
FROM alpine:latest

ENV TZ UTC
ENV PYTHONUNBUFFERED=1

RUN apk update && apk upgrade && apk --no-cache --update add --virtual \
    build-dependencies gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev curl \
    bash wpa_supplicant make freeradius freeradius-python3 freeradius-mysql freeradius-eap \
    openssl build-base gcc libc-dev \
    mysql mysql-client mysql-dev nginx python3 py3-pip \ 
    && python3 && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools py-radius PyMySQL \
    # && wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
    # && unzip awscli-bundle.zip \
    # && rm awscli-bundle.zip \
    # && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    # && rm -r ./awscli-bundle \
    && mkdir -p /tmp/radiusd /etc/raddb && openssl dhparam -out /etc/raddb/dh 1024 \
    && mkdir -p /etc/raddb/certs \
    && rm -fr /etc/raddb/sites-enabled/* 

COPY radius /etc/raddb
COPY ./radius/clients.conf /etc/raddb/clients.conf
COPY ./test_certs/ ./test_certs
COPY ./radius/sites-enabled/ /etc/raddb/sites-enabled
COPY ./scripts /scripts
COPY ./test /test

EXPOSE 1812/udp 1813/udp 18120/udp 2083/tcp

CMD /scripts/bootstrap.sh 
