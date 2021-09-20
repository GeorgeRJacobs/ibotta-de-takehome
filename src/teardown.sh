#!/bin/zsh

echo "Deleting bucket "$1"-script and its contents"
aws s3 rm s3://$1-script --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $1-script --output text >> tear_down.log

echo "Deleting bucket "$1"-landing-zone and its contents"
aws s3 rm s3://$1-landing-zone --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $1-landing-zone --output text >> tear_down.log

echo "Deleting bucket "$1"-clean-data and its contents"
aws s3 rm s3://$1-clean-data --recursive --output text >> tear_down.log
aws s3api delete-bucket --bucket $1-clean-data --output text >> tear_down.log

echo "Tearing down EMR cluster"
EMR_CLUSTER_ID=$(aws emr list-clusters --active --query 'Clusters[?Name==`sde-lambda-etl-cluster`].Id' --output text)
aws emr terminate-clusters --cluster-ids $EMR_CLUSTER_ID >> tear_down.log

echo "Waiting for Teardown of EMR"
EMR_CLUSTER_ID=$(aws emr list-clusters --cluster-states STARTING --query 'Clusters[?Name==`detakehome`].Id' --output text)
aws emr wait cluster-running --cluster-id $EMR_CLUSTER_ID

echo "Deleting Key Pair"
aws ec2 delete-key-pair --key-name DE_TAKEHOME_ANALYSIS


rm -f setup.log
rm -f tear_down.log