#!/usr/bin/env python3

import argparse
import json
import logging
import datetime
import os

import boto3
from botocore.exceptions import ClientError

logging.basicConfig(format='[%(asctime)s] %(levelname)s - %(message)s', level=logging.INFO)

emr_client = boto3.client('emr')


def main():
    """
    Performs the main update logic.
    :return:
    """
    # Loads most recent cluster created
    # Requires the start_emr script to run.
    with open('cluster_profile.json') as f:
        cl_dict = json.load(f)

    args = parse_args()
    params = get_parameters()
    steps = get_steps(params, args.job_type)

    add_job_flow_steps(cl_dict['ClusterId'], steps)


def add_job_flow_steps(cluster_id: str, steps: list) -> bool:
    """
    Add steps to an existing cluster
    :param cluster_id: ID of the EMR cluster
    :param steps: The associated steps getting sent to the EMR cluster
    :return: True if success, False if fail
    """

    try:
        response = emr_client.add_job_flow_steps(
            JobFlowId=cluster_id,
            Steps=steps
        )

        print(f'Response: {response}')
    except ClientError as e:
        logging.error(e)
        return False
    return True


def get_steps(params: dict, job_type: str):
    """
    Loads the steps from the JSON file
    :param params: Dictates various parameters associated with the job.
    :param job_type: What kind of json are we running
    :return: List of the steps to be sent to the EMR cluster
    """

    # Set arguments to be passed to the JSON files.
    params['exec_date'] = datetime.date.today().strftime("%Y-%m-%d")
    with open(f'src/remote/task_2/job_steps/jobs_{job_type}.json', 'r') as file:
        steps = json.load(file)
        new_steps = []
        for step in steps:
            step['HadoopJarStep']['Args'] = list(
                map(lambda x: x.format(**params), step['HadoopJarStep']['Args']))
            new_steps.append(step)

        return new_steps


def get_parameters() -> dict:
    """
    Loads configuration variables for the task.
    :return: Dictionary of values
    """

    with open('config.json') as f:
        config = json.load(f)

    return config


def parse_args():
    """Parse argument values from command-line"""

    parser = argparse.ArgumentParser(description='Arguments required for script.')
    parser.add_argument('-t', '--job-type', required=True, choices=['process', 'analyze'],
                        help='process or analysis')
    args = parser.parse_args()
    return args


if __name__ == '__main__':
    main()
