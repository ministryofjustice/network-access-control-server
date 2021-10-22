#!/bin/bash

docker cp radius-server:"/usr/share/freeradius/" .
aws s3 sync ./freeradius/ s3://${RADIUS_CONFIG_BUCKET_NAME}/radius_dictionaries/ --exclude "*" --include "dictionary.*"
rm -rf ./freeradius
