#!/bin/zsh

STAGING=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['bronze_bucket'])"`
PROCESS=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['silver_bucket'])"`
LOGS=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['logs_bucket'])"`
WORK=`cat config.json | python3 -c "import sys, json; print(json.load(sys.stdin)['work_bucket'])"`

echo "Deleting buckets"
aws s3 rm s3://detakehomenotebooks --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket detakehomenotebooks --output text >> tear_down.log

aws s3 rm s3://$LOGS --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $LOGS --output text >> tear_down.log

aws s3 rm s3://$PROCESS --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $PROCESS --output text >> tear_down.log

aws s3 rm s3://$STAGING --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $STAGING --output text >> tear_down.log

aws s3 rm s3://$WORK --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $WORK --output text >> tear_down.log

echo "Tearing down EMR cluster"
EMR_CLUSTER_ID=$(aws emr list-clusters --active --query 'Clusters[?Name==`detakehome`].Id' --output text)
[ -z "$EMR_CLUSTER_ID" ] && echo "No Active EMR Clusters" || \
aws emr terminate-clusters --cluster-ids $EMR_CLUSTER_ID >> tear_down.log

echo "Deleting Key Pair"
aws ec2 delete-key-pair --key-name DE_TAKEHOME_ANALYSIS

echo "Removing Local files (in Project)"
exec_date=$(date '+%Y-%m-%d')
rm -f setup.log
rm -f tear_down.log
rm -f cluster_profile.json
rm -f port_forwarding.log
rm -r data/takehome-process/$exec_date
rm -r data/takehome-staging/$exec_date
rm -f DE_TAKEHOME_ANALYSIS.pem