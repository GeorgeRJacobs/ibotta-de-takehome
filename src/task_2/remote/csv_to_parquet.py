#!/usr/bin/env python3

import argparse

from pyspark.sql import SparkSession


def main():
    """
    Conversion logic of our CSVs to Parquet on Spark
    :return:
    """
    args = parse_args()

    spark = SparkSession \
        .builder \
        .appName("csv-to-parquet") \
        .getOrCreate()

    convert_to_parquet(spark, args.filename, args)


def convert_to_parquet(spark: SparkSession, file: str, args: argparse.Namespace):
    """
    Meat of the conversion logic
    :param spark: Spark Session object.
    :param file: Filename of the CSV
    :param args: Additional arguments handling the file creation.
    :return:
    """
    df = spark.read \
        .format("csv") \
        .option("header", "true") \
        .option("delimiter", ",") \
        .option("inferSchema", "true") \
        .load(f"s3a://{args.bronze_bucket}/{args.execution_date}/{file}")

    df.write \
        .format("parquet") \
        .save(f"s3a://{args.silver_bucket}/{args.execution_date}/", mode="overwrite")


def parse_args():
    """
    Parses the arguments from the command-line.
    :return:
    """

    parser = argparse.ArgumentParser(description="Arguments required for script.")
    # Bronze / Silver bucket notation important for knowing what data
    parser.add_argument("--file_name", required=True, help="File to convert")
    parser.add_argument("--execution_date", required=True, help="Execution date of request")
    parser.add_argument("--bronze-bucket", required=True, help="Raw data location")
    parser.add_argument("--silver-bucket", required=True, help="Processed data location")

    args = parser.parse_args()
    return args


if __name__ == "__main__":
    main()
