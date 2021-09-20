from pyspark.sql import SparkSession
import logging
import os
from pathlib import Path
from datetime import date
import json


def main():
    """
    Runs the local logic for processsing our data files.
    :return:
    """
    current_date = date.today().strftime("%Y-%m-%d")
    params = get_parameters()

    # Create Local Directories - Assumes we are still at the top of the project directory.
    Path(os.path.join('data', params.get('silver_bucket'))).mkdir(parents=True, exist_ok=True)

    # Create SparkSession
    spark = SparkSession \
        .builder \
        .appName('Convert CSV to Parquet') \
        .getOrCreate()

    # Write datastore
    outcome_service = make_queryable_datastore(
        spark,
        os.path.join('data', params.get('bronze_bucket'), current_date, 'service_data.csv'),
        os.path.join('data', params.get('silver_bucket'), current_date, 'service_data.parquet'))

    outcome_traffic = make_queryable_datastore(
        spark,
        os.path.join('data', params.get('bronze_bucket'), current_date, 'traffic_accidents.csv'),
        os.path.join('data', params.get('silver_bucket'), current_date, 'traffic_accidents.parquet'))

    if outcome_service and outcome_traffic:
        logging.info('Data Load Successful')
    else:
        logging.info('Error Loading Data. Check Logs.')


def make_queryable_datastore(spark: SparkSession, input_loc: str, output_loc: str) -> bool:
    """
    Converts DL'd file to parquet format using Pyspark.
    :param spark: Spark Session
    :param input_loc: Raw Data file location
    :param output_loc: Output file location
    :return: True if successful otherwise False with logged Error
    """
    try:
        logging.info('Spark Session Created')
        data = spark.read.option('header', True).format("csv").load(input_loc)
        # Clean up the column names for parquet
        col_names = ["_".join(x.lower().split()) for x in data.schema.names]
        data2 = data.toDF(*col_names)
        logging.info('CSV Loaded')
        data2.write.mode('overwrite').parquet(output_loc)
        logging.info('Parquet File Written')
    except Exception as e:
        logging.warning(e)
        return False
    return True


def get_parameters() -> dict:
    """
    Loads configuration variables for the task.
    :return:
    """

    with open('config.json') as f:
        config = json.load(f)
        params = {
            'bronze_bucket': config['bronze_bucket'],
            'silver_bucket': config['silver_bucket']
        }

    return params


if __name__ == "__main__":
    main()
