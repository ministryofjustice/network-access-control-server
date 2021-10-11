ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/network-access-control-server:ubuntu-20-04

ENV TZ=UTC
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH="/usr/lib/python3.8:/usr/lib/python3/dist-packages/"
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libpython3.8.so"

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    gnupg tzdata openssl libssl-dev nettle-dev curl freeradius freeradius-python3 python-six python3-debian python3-dev libpython3.8-dev python3-pymysql \
    python3 python3-pip wget unzip python3.8-venv \
    && python3 && ln -sf python3 /usr/bin/python \
    && pip3 install --ignore-installed --no-cache --upgrade pip six setuptools py-radius PyMySQL

RUN wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && rm awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -r ./awscli-bundle 

RUN mkdir -p /tmp/radiusd \
    && mkdir -p /etc/freeradius/3.0/certs \
    && rm -fr /etc/freeradius/3.0/sites-enabled/* \
    && chown -R freerad:freerad /tmp/radiusd

COPY --chown=freerad:freerad ./radius /etc/freeradius/3.0/
COPY --chown=freerad:freerad ./scripts /scripts

USER freerad

EXPOSE 1812/udp 1813/udp 18120/udp 2083/tcp

CMD /scripts/bootstrap.sh 
