from pyspark.sql import SparkSession
import logging
import os
from pathlib import Path
from datetime import date
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))


def make_queryable_datastore(input_loc: str, output_loc: str) -> bool:
    """
    Converts DL'd file to parquet format using Pyspark.
    :param input_loc: Raw Data file location
    :param output_loc: Output file location
    :return: True if successful otherwise False with logged Error
    """
    try:
        spark = SparkSession.builder.appName('Convert CSV to Parquet').getOrCreate()
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


if __name__ == "__main__":
    current_date = date.today().strftime("%Y-%m-%d")
    bucket_name = os.getenv('S3_BUCKET_NAME')

    # Create Local Directories - Assumes we are still at the top of the project directory.
    Path('data/takehome-processed').mkdir(parents=True, exist_ok=True)

    # Write datastore
    outcome_service = make_queryable_datastore(
        os.path.join('data', bucket_name + '-raw', current_date, 'service_data.csv'),
        os.path.join('data', bucket_name + '-processed', current_date, 'service_data.parquet'))

    outcome_traffic = make_queryable_datastore(
        os.path.join('data', bucket_name + '-raw', current_date, 'traffic_accidents.csv'),
        os.path.join('data', bucket_name + '-processed', current_date, 'traffic_accidents.parquet'))

    if outcome_service and outcome_traffic:
        logging.info('Data Load Successful')
    else:
        logging.info('Error Loading Data. Check Logs.')
