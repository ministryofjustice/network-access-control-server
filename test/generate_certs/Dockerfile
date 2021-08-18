ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/network-access-control-test-certs:alpine-3-13-0

ENV TZ UTC
ENV PYTHONUNBUFFERED=1

RUN apk update && apk upgrade && apk --no-cache --update add --virtual \
    build-dependencies gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev curl \
    bash wpa_supplicant make freeradius freeradius-eap \
    openssl build-base gcc libc-dev 

COPY client_crl.cnf /etc/raddb/certs
COPY bootstrap.sh /

WORKDIR /etc/raddb/certs