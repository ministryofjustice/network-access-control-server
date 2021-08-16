ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/alpine:alpine-3-14-0

ENV TZ UTC
ENV PYTHONUNBUFFERED=1

RUN apk update && apk upgrade && apk --no-cache --update add --virtual \
    build-dependencies gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev curl \
    bash wpa_supplicant make freeradius freeradius-eap \
    openssl build-base gcc libc-dev 

WORKDIR /etc/raddb/certs