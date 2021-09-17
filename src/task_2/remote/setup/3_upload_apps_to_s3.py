#!/usr/bin/env python3

import logging
import os
import json
import boto3
from botocore.exceptions import ClientError

logging.basicConfig(format='[%(asctime)s] %(levelname)s - %(message)s', level=logging.INFO)

s3_client = boto3.client('s3')


def main() -> None:
    """
    Sends PySpark applications to S3.
    :return:
    """
    params = get_parameters()

    # upload files
    dir_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    print(dir_path)
    path = f'{dir_path}/pyspark_apps/'
    bucket_name = params['work_bucket']
    upload_directory(path, bucket_name)


def upload_directory(path: str, bucket_name: str) -> None:
    """
    Uploads a directory of Pyspark Applications to S3.
    :param path: Path of the Pyspark Files
    :param bucket_name: Work bucket which we reference in our spark-submit jobs
    :return: None
    """
    for root, dirs, files in os.walk(path):
        for file in files:
            print(file)
            try:
                if file != '.DS_Store':
                    file_directory = os.path.basename(os.path.dirname(os.path.join(root, file)))
                    key = f'{file_directory}/{file}'
                    print('Key:',  key)
                    print('Path: ', os.path.join(root, file))
                    s3_client.upload_file(os.path.join(root, file), bucket_name, key)
                    print(f'File {key} uploaded to bucket {bucket_name} as {key}')
            except ClientError as e:
                logging.error(e)


def get_parameters() -> dict:
    """
    Loads configuration variables for the task.
    :return:
    """

    with open('config.json') as f:
        config = json.load(f)
        params = {
            'work_bucket': config['work_bucket']
        }

    return params


if __name__ == '__main__':
    main()
