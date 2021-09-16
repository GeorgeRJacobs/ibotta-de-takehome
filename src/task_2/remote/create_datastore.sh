#!/bin/zsh

# Source ENV file
# No whitespaces in naming of vars
echo
set -a
source .env
set +a

# Create Buckets - creating a log file in case of issues
# Buckets are public since this is free data. Beware of security issues.
STAGING=$S3_BUCKET_NAME-process
LOGS=$S3_BUCKET_NAME-logs
WORK=$S3_BUCKET_NAME-work

echo "Creating bucket "$STAGING""
aws s3api create-bucket --acl public-read-write --bucket $STAGING --output text > setup.log

echo "Creating bucket LOGS"
aws s3api create-bucket --acl public-read-write --bucket $LOGS --output text > setup.log

echo "Creating bucket WORK"
aws s3api create-bucket --acl public-read-write --bucket $WORK --output text > setup.log