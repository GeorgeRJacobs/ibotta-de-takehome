#!/bin/zsh

# Create Buckets - creating a log file in case of issues
# Buckets are public since this is free data. Beware of security issues.
echo "Reading Bucket Name"
STAGING=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['bronze_bucket'])"`

echo "Creating bucket "$BUCKET""
aws s3api create-bucket --acl public-read-write --bucket $STAGING --output text > setup.log

# Stream (Pipe) Data from Curl to new S3 Bucket
echo "Streaming 311 Service to S3"
curl "https://www.denvergov.org/media/gis/DataCatalog/311_service_data/csv/311_service_data_2015.csv" | aws s3 cp - s3://$STAGING/$(date +%Y-%m-%d)/service_data.csv

echo "Streaming Traffic Accidents"
curl "https://www.denvergov.org/media/gis/DataCatalog/traffic_accidents/csv/traffic_accidents.csv" | aws s3 cp - s3://$STAGING/$(date +%Y-%m-%d)/traffic_accidents.csv

echo "Streaming Complete"
