#!/bin/zsh

echo "Reading Bucket Names"
PROCESS=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['silver_bucket'])"`
LOGS=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['logs_bucket'])"`
WORK=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['work_bucket'])"`

echo "Creating bucket PROCESS"
aws s3api create-bucket --acl public-read-write --bucket $PROCESS --output text > setup.log

echo "Creating bucket LOGS"
aws s3api create-bucket --acl public-read-write --bucket $LOGS --output text > setup.log

echo "Creating bucket WORK"
aws s3api create-bucket --acl public-read-write --bucket $WORK --output text > setup.log

echo "Creating Persistent Jupyter Storage"
aws s3api create-bucket --acl public-read-write --bucket detakehomenotebooks --output text > setup.log