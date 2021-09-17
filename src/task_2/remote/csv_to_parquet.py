import os

import boto3
from pyspark.sql import SparkSession


def main():
    params = get_parameters()

    spark = SparkSession \
        .builder \
        .appName("csv-to-parquet") \
        .getOrCreate()

    convert_to_parquet(spark, "bakery", params)


def convert_to_parquet(spark, file, params):
    df = spark.read \
        .format("csv") \
        .option("header", "true") \
        .option("delimiter", ",") \
        .option("inferSchema", "true") \
        .load(f"s3a://{params['bronze_bucket']}/bakery/{file}.csv")

    write_parquet(df, params)


def write_parquet(df_bakery, params):
    df_bakery.write \
        .format("parquet") \
        .save(f"s3a://{params['silver_bucket']}/bakery/", mode="overwrite")


def get_parameters():
    """Load parameter values from AWS Systems Manager (SSM) Parameter Store"""

    params = {
        'bronze_bucket': ssm_client.get_parameter(Name='/emr_demo/bronze_bucket')['Parameter']['Value'],
        'silver_bucket': ssm_client.get_parameter(Name='/emr_demo/silver_bucket')['Parameter']['Value']
    }

    return params


if __name__ == "__main__":
    main()
