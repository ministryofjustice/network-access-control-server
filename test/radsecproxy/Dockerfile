ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/network-access-control-test-certs:alpine-3-13-0

ENV RADSECPROXY_VERSION 1.9.0

RUN apk update && apk upgrade && \
    apk --no-cache --update add --virtual build-dependencies build-base curl gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev openssl && \
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

RUN touch /var/run/radsecproxy/radsecproxy.pid 

COPY ./radsecproxy.conf /etc/

EXPOSE 18120/udp

CMD openssl rehash ./certs && /sbin/radsecproxy -c /etc/radsecproxy.conf -i /var/run/radsecproxy/radsecproxy.pid -f