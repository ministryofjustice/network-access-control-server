#!/bin/bash

set -e

if [ "$1" != "true" ]; then
apk add --no-cache aws-cli
fi

