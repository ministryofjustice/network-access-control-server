FROM alpine:3.15.0
ARG LOCAL_DEVELOPMENT=false
ENV PYTHONUNBUFFERED=1
ENV LOCAL_DEVELOPMENT=$LOCAL_DEVELOPMENT

RUN apk --update --no-cache add \
  freeradius~=3.0.25 freeradius-python3 freeradius-eap openssl jq tshark python3-dev py3-pip bash make curl \
  && mkdir -p /tmp/radiusd /etc/raddb /etc/raddb/certs \
  && openssl dhparam -out /etc/raddb/dh 1024 && ln -sf python3 /usr/bin/python \
  && pip3 install --ignore-installed --no-cache --upgrade pip six setuptools py-radius PyMySQL \
  && rm -fr /etc/raddb/sites-enabled/* && chown -R radius:radius /tmp/radiusd /usr/bin/dumpcap

RUN ls -al
COPY --chown=radius:radius ./scripts /scripts
COPY --chown=radius:radius ./radius /etc/raddb
RUN /scripts/install_aws_sdk.sh ${LOCAL_DEVELOPMENT}
EXPOSE 1812/udp 2083/tcp

CMD /scripts/bootstrap.sh
