ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/alpine:alpine-3-14-0

ENV TZ UTC
ENV PYTHONUNBUFFERED=1
ENV RADSECPROXY_VERSION 1.9.0

RUN apk update && apk upgrade && apk --no-cache --update add --virtual \
    build-dependencies gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev curl \
    bash wpa_supplicant make freeradius freeradius-python3 freeradius-eap \
    openssl build-base gcc libc-dev \
    mysql mysql-client mysql-dev nginx python3 py3-pip \ 
    && python3 && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools py-radius PyMySQL \
    && wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && rm awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -r ./awscli-bundle \
    && mkdir -p /tmp/radiusd /etc/raddb && openssl dhparam -out /etc/raddb/dh 1024 \
    && mkdir -p /etc/raddb/certs \
    && rm -fr /etc/raddb/sites-enabled/* 

RUN apk update && apk upgrade && \
    apk --no-cache --update add --virtual build-dependencies build-base curl gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev && \
    adduser -D -u 52000 radsecproxy && \
    curl -sLo radsecproxy-${RADSECPROXY_VERSION}.tar.gz  \
        https://github.com/radsecproxy/radsecproxy/releases/download/${RADSECPROXY_VERSION}/radsecproxy-${RADSECPROXY_VERSION}.tar.gz && \
    curl  -sLo radsecproxy-${RADSECPROXY_VERSION}.tar.gz.asc \
        https://github.com/radsecproxy/radsecproxy/releases/download/${RADSECPROXY_VERSION}/radsecproxy-${RADSECPROXY_VERSION}.tar.gz.asc && \
    curl -sS https://radsecproxy.github.io/fabian.mauchle.asc | gpg --import - && \
    gpg --verify radsecproxy-${RADSECPROXY_VERSION}.tar.gz.asc \
                 radsecproxy-${RADSECPROXY_VERSION}.tar.gz && \
    rm  radsecproxy-${RADSECPROXY_VERSION}.tar.gz.asc && \
    tar xvf radsecproxy-${RADSECPROXY_VERSION}.tar.gz && \
    rm radsecproxy-${RADSECPROXY_VERSION}.tar.gz &&\
    cd radsecproxy-${RADSECPROXY_VERSION} && \
    ./configure --prefix=/ && \
    make && \
    make check && \
    make install && \
    mkdir /var/log/radsecproxy/ /var/run/radsecproxy && \
    touch /var/log/radsecproxy/radsecproxy.log && \
    chown -R radsecproxy:radsecproxy /var/log/radsecproxy /var/run/radsecproxy && \
    apk del build-dependencies && \
    rm -rf /etc/apk/* /var/cache/apk/* /root/.gnupg

USER radsecproxy

COPY radius /etc/raddb
COPY ./radius/clients.conf /etc/raddb/clients.conf
COPY ./test_certs/ ./test_certs
COPY ./radius/sites-enabled/ /etc/raddb/sites-enabled
COPY ./scripts /scripts
COPY ./test /test
COPY ./test/radsecproxy.conf /etc/

RUN touch /var/run/radsecproxy/radsecproxy.pid && /sbin/radsecproxy -i "/var/run/radsecproxy/radsecproxy.pid" 

EXPOSE 1812/udp 1813/udp 18120/udp 2083/tcp

CMD /scripts/bootstrap.sh 
