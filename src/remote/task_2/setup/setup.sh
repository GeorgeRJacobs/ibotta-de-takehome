#!/bin/zsh

echo "Setting up Remote Environment"
zsh src/remote/task_2/setup/1_create_datastore.sh > setup.log
zsh src/remote/task_2/setup/2_start_emr.sh
python3 src/remote/task_2/setup/3_upload_apps_to_s3.py