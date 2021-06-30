ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/admin:ruby-2-7-1-alpine3-12

ENV TZ UTC
ENV PYTHONUNBUFFERED=1

RUN apk update && apk upgrade && apk --no-cache --update add --virtual \
    build-dependencies gnupg && \
    apk --no-cache add iptables nmap nmap-scripts tzdata nettle-dev openssl-dev curl tshark \
    bash vim wpa_supplicant make freeradius freeradius-mysql freeradius-eap \
    openssl build-base gcc libc-dev \
    mysql mysql-client mysql-dev nginx python3 py3-pip \ 
    && python3 && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools \
    && wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && rm awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -r ./awscli-bundle

RUN mkdir -p /tmp/radiusd /etc/raddb && openssl dhparam -out /etc/raddb/dh 1024
COPY radius /etc/raddb
RUN chown root /usr/bin/dumpcap

COPY ./radius/clients.conf /etc/raddb/clients.conf

RUN mkdir -p /etc/raddb/certs
COPY ./test_certs/ ./certs

RUN rm -fr /etc/raddb/sites-enabled/*
COPY ./radius/sites-enabled/ /etc/raddb/sites-enabled
COPY ./scripts /scripts

COPY ./test /test

EXPOSE 1812/udp 1813/udp 18120/udp 2083/tcp

CMD /scripts/bootstrap.sh 
