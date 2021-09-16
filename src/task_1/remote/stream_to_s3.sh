#!/bin/zsh

# Source ENV file
# No whitespaces in naming of vars
echo
set -a
source .env
set +a

# Create Buckets - creating a log file in case of issues
# Buckets are public since this is free data. Beware of security issues.
STAGING=$S3_BUCKET_NAME-sts

echo "Creating bucket "$STAGING""
aws s3api create-bucket --acl public-read-write --bucket $STAGING --output text > setup.log

# Stream (Pipe) Data from Curl to new S3 Bucket
echo "Streaming 311 Service to S3"
curl "https://www.denvergov.org/media/gis/DataCatalog/311_service_data/csv/311_service_data_2015.csv" | aws s3 cp - s3://$STAGING/$(date +%Y-%m-%d)/service_data.csv

echo "Streaming Traffic Accidents"
curl "https://www.denvergov.org/media/gis/DataCatalog/traffic_accidents/csv/traffic_accidents.csv" | aws s3 cp - s3://$STAGING/$(date +%Y-%m-%d)/traffic_accidents.csv

echo "Streaming Complete"
