#!/bin/bash

set -e

if ! [ "$LOCAL_DEVELOPMENT" == "true" ]; then
  wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
  && unzip awscli-bundle.zip \
  && rm awscli-bundle.zip \
  && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && rm -r ./awscli-bundle
fi