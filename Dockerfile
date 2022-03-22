FROM alpine:3.15.0
ARG LOCAL_DEVELOPMENT=false
ENV PYTHONUNBUFFERED=1
ENV LOCAL_DEVELOPMENT=$LOCAL_DEVELOPMENT

RUN apk --update --no-cache add \
  git openssl~=1.1.1n jq tshark python3-dev py3-pip bash make curl gcc make g++ zlib-dev talloc-dev libressl openssl-dev linux-headers

RUN git clone https://github.com/FreeRADIUS/freeradius-server.git \
    && cd freeradius-server \
    && git checkout dc11c2baae78a0f292ba377cfe25ea0d67d60e6a \
    && ./configure --build=x86_64-unknown-linux-gnu \
    && make \
    && make install \
    && mkdir -p /tmp/radiusd /usr/local/etc/raddb /usr/local/etc/raddb/certs \
    && rm -fr /usr/local/etc/raddb/sites-enabled/* \
    && openssl dhparam -out /usr/local/etc/raddb/dh 1024 && ln -sf python3 /usr/bin/python \
    && pip3 install --ignore-installed --no-cache --upgrade pip six setuptools py-radius PyMySQL \
    && cd - \
    && rm -fr ./freeradius-server

COPY ./scripts /scripts
COPY ./radius /usr/local/etc/raddb
RUN /scripts/install_aws_sdk.sh ${LOCAL_DEVELOPMENT}
EXPOSE 1812/udp 2083/tcp

CMD /scripts/bootstrap.sh
