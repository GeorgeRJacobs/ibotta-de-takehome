#!/bin/zsh

# Source ENV file
# No whitespaces in naming of vars
echo
set -a
source .env
set +a

echo "Creating local directory"
mkdir -p data/$S3_BUCKET_NAME-raw/$(date +%Y-%m-%d)

echo "Downloading 311 Service Locally"
curl "https://www.denvergov.org/media/gis/DataCatalog/311_service_data/csv/311_service_data_2015.csv" -o data/takehome-raw/$(date +%Y-%m-%d)/service_data.csv > setup.log

echo "Downloading Traffic Accidents"
curl "https://www.denvergov.org/media/gis/DataCatalog/traffic_accidents/csv/traffic_accidents.csv" -o data/takehome-raw/$(date +%Y-%m-%d)/traffic_accidents.csv > setup.log

echo "Downloads Complete"
