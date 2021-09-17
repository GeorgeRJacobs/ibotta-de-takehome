#!/bin/zsh

echo "Reading Bronze Bucket"
BUCKET=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['bronze_bucket'])"`
echo $BUCKET

echo "Creating local directory"
mkdir -p data/$BUCKET/$(date +%Y-%m-%d)

echo "Downloading 311 Service Locally"
curl "https://www.denvergov.org/media/gis/DataCatalog/311_service_data/csv/311_service_data_2015.csv" -o data/$BUCKET/$(date +%Y-%m-%d)/service_data.csv > setup.log

echo "Downloading Traffic Accidents"
curl "https://www.denvergov.org/media/gis/DataCatalog/traffic_accidents/csv/traffic_accidents.csv" -o data/$BUCKET/$(date +%Y-%m-%d)/traffic_accidents.csv > setup.log

echo "Downloads Complete"
