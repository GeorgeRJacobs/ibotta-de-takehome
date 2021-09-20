#!/bin/zsh

echo "Deleting buckets"
aws s3 rm s3://detakehomenotebooks --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket detakehomenotebooks --output text >> tear_down.log

aws s3 rm s3://takehome-logs --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket takehome-logs --output text >> tear_down.log

aws s3 rm s3://takehome-process --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket takehome-process --output text >> tear_down.log

aws s3 rm s3://takehome-staging --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket takehome-staging --output text >> tear_down.log

aws s3 rm s3://takehome-work --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket takehome-work --output text >> tear_down.log

echo "Tearing down EMR cluster"
EMR_CLUSTER_ID=$(aws emr list-clusters --active --query 'Clusters[?Name==`detakehome`].Id' --output text)
[ -z "$EMR_CLUSTER_ID" ] && echo "No Active EMR Clusters" || \
aws emr terminate-clusters --cluster-ids $EMR_CLUSTER_ID >> tear_down.log

echo "Deleting Key Pair"
aws ec2 delete-key-pair --key-name DE_TAKEHOME_ANALYSIS


rm -f setup.log
rm -f tear_down.log