FROM ubuntu:20.04
ARG LOCAL_DEVELOPMENT=false
ENV TZ=UTC
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV LOCAL_DEVELOPMENT=$LOCAL_DEVELOPMENT
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu/:/usr/lib/python3.8/config-3.8-x86_64-linux-gnu/"

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    gnupg tzdata openssl libssl-dev nettle-dev curl freeradius freeradius-python3 python3-debian python3-dev python3-pymysql \
    python3 python3-pip wget unzip tshark jq \
    && pip3 install --ignore-installed --no-cache --upgrade pip six setuptools py-radius PyMySQL \
    && mkdir -p /tmp/radiusd \
    && mkdir -p /etc/freeradius/3.0/certs \
    && rm -fr /etc/freeradius/3.0/sites-enabled/* \
    && chown -R freerad:freerad /tmp/radiusd

COPY --chown=freerad:freerad ./radius /etc/freeradius/3.0/
COPY --chown=freerad:freerad ./scripts /scripts

RUN /scripts/install_aws_sdk.sh ${LOCAL_DEVELOPMENT}

EXPOSE 1812/udp 1813/udp 18120/udp 2083/tcp

CMD /scripts/bootstrap.sh
