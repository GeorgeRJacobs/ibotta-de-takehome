## Ibotta Data Engineer Project

### Philosophy

The goal of this project is to showcase ways of interacting with existing
datasets too large to fit into memory. Example data is found
at [311 Service](https://www.denvergov.org/media/gis/DataCatalog/311_service_data/csv/311_service_data_2015.csv)
and [Traffic Data](https://www.denvergov.org/media/gis/DataCatalog/traffic_accidents/csv/traffic_accidents.csv)

These datasets are periodically updated with more information (or additional
years are released) and so the way we query this data needs to be flexible.

#### Technology

##### Apache Spark.

This is a perfect use-case for Spark for a few reasons:

1. Scale. Apache Spark is designed to handle enterprise levels of datasets. As
   the data size increases, it becomes far more likely you cannot run things
   locally or on an EC2 instance. In that case, you need to move to distributed
   systems for handling large computations.
2. Speed. Exploring your big data interactively is possible using
   implementations of Spark such as Pyspark.
3. Syntax. Spark (in particular PySpark) allows the user to use familiar
   Pandas-like syntax to query & transform datasets. In addition, SQL is
   available for users who prefer the declarative style of coding.
4. Support. Most major cloud providers have implementations available to set up
   for many use cases.

### Prerequisites

1. Apache Spark (Setup to follow)
2. git
3. .env file
    1. Unless you want to play around with these settings, I recommend leaving
       them as laid out. These are used for some remote-based code.
4. Optional (If following remote code)
    1. AWS Account
    2. AWS CLI Configured

### Setup

#### Spark (Local)

In order to start using Apache Spark locally, you will need to install a local
copy. Fortunately, Python users have an easy way to get started.
Simply `pip install pyspark` in your environment will be enough to get a copy
installed locally. It is recommended to use a virtual environment for this step
of the process.

To begin using it, you write `pyspark` in your local shell to start a local
instance.

#### Amazon Web Services (AWS)

If you would like to follow the remote code, you will need to have an active AWS
Account & preferably an IAM Administrator account set up. In addition, this
sample code uses AWS CLI to perform some operations.

The easiest option to get setup is to use: `aws configure` to configure your
settings.

### Task 1

NOTE: All code expects the working directory set to the project. As mentioned
above, it is a good idea to create a virtual env to run project code.

Under the src directory, I have a directory for each task. There will be 2 sets
of files which you can run, local & remote. These showcase how I would use these
tools both in a local capacity and as well using cloud technologies.

This ask requires us to download the data from the Denver Gov't website &
prepare for the next set of tasks.

#### Local:

```shell
zsh src/task_1/local/dl_local.sh
```

This will download the datasets to your local machine under the
`/data/takehome-raw` directory. Out of the box, the shell can download large
(> 1GB) files without complaint. This is reliant on your local internet
connection.

#### Remote:

The remote version of this code would instead of sending this data to our local
machine place itself into an S3 bucket. You can set the bucket name of your
implementation under the `.env` file.

```shell
zsh src/task_1/local/stream_to_s3.sh
```

The AWS CLI has the capacity for large data uploads of file sizes > 1GB. Using
this multi-part upload process, the transfer is limited by bandwidth & not
memory. Included in the bash code, we add a date to the file directory to make
sure we can make future data runs idempotent. If we ever needed to re-run the
datasets in the future, there would not be a data overwrite. This assumes we'd
run the job on a daily cadence.

### Task 2

For this section, we need to make this dataset queryable by our Spark engine.
For the local implementation of the files, this is not really a problem. Spark
includes the ability to perform operations on CSVs. However, in order to
showcase a large data file, it is usually advisable to convert these types of
files into a columnar format such as Parquet. The main reason for doing is
speed. Certain operations will be eagerly evaluated when using CSVs creating
long run times (and potentially memory issues) whereas Parquet is optimized for
Spark workloads.

#### Local

Our local implementation uses Spark to convert the data files into parquet files
located at `data/takehome-converted`.

```zsh
spark-submit --master "local[3]" src/task_2/local/create_datastore.py
```

Running the above code in your terminal will create both files in parquet format
optimized for Spark. One note here is that `local[3]` will use 3 parallel
threads to process your application.

#### Remote

The primary difference of the remote implementation is that we will be setting
up a small AWS EMR cluster to run our data jobs. The primary steps are:

1. Create & setup an EMR cluster on AWS.
2. Once started, submit spark job to convert the S3 csv to HDFS as a parquet
   file. 











