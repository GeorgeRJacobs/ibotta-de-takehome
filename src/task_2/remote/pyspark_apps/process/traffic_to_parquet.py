#!/usr/bin/env python3

import argparse

from pyspark.sql import SparkSession


def main():
    args = parse_args()

    spark = SparkSession \
        .builder \
        .appName("traffic-csv-to-parquet") \
        .getOrCreate()

    convert_to_parquet(spark, "traffic_accidents", args)


def convert_to_parquet(spark, file, args):
    df = spark.read \
        .format("csv") \
        .option("header", "true") \
        .option("delimiter", ",") \
        .option("inferSchema", "true") \
        .load(f"s3a://{args.bronze_bucket}/{args.exec_date}/{file}.csv")

    col_names = ["_".join(x.lower().split()) for x in df.schema.names]
    df2 = df.toDF(*col_names)

    df2.write \
        .format("parquet") \
        .save(f"s3a://{args.silver_bucket}/{args.exec_date}/traffic_accidents/", mode="overwrite")


def parse_args():
    """Parse argument values from command-line"""

    parser = argparse.ArgumentParser(description="Arguments required for script.")
    parser.add_argument("--exec-date", required=True, help="Execution Date of the Job - YYYY-MM-DD")
    parser.add_argument("--bronze-bucket", required=True, help="Raw data location")
    parser.add_argument("--silver-bucket", required=True, help="Processed data location")

    args = parser.parse_args()
    return args


if __name__ == "__main__":
    main()