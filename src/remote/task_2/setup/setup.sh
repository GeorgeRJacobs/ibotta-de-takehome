#!/bin/zsh

echo "Creating Processing Buckets"
zsh src/remote/task_2/setup/1_create_datastore.sh > setup.log
echo "Creating & Starting EMR Cluster. Assumes you don't have one already"
zsh src/remote/task_2/setup/2_start_emr.sh
echo "Uploads PySpark scripts to S3"
python3 src/remote/task_2/setup/3_upload_apps_to_s3.py