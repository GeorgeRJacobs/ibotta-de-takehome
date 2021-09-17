import json
import datetime

def get_parameters() -> dict:
    """
    Loads configuration variables for the task.
    :return: Dictionary of values
    """

    with open('config.json') as f:
        config = json.load(f)

    return config

def get_steps(params: dict, job_type: str):
    """
    Loads the steps from the JSON file
    :param params: Dictates various parameters associated with the job.
    :param job_type: What kind of json are we running
    :return: List of the steps to be sent to the EMR cluster
    """

    # Set arguments to be passed to the JSON files.
    params['exec_date'] = datetime.date.today().strftime("%Y-%m-%d")
    with open(f'src/task_2/remote/job_steps/jobs_{job_type}.json', 'r') as file:
        steps = json.load(file)
        new_steps = []
        for step in steps:
            step['HadoopJarStep']['Args'] = list(
                map(lambda x: x.format(**params), step['HadoopJarStep']['Args']))
            new_steps.append(step)

        return new_steps

t =get_steps(get_parameters(), 'process')