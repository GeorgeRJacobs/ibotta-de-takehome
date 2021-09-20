# Ibotta Data Engineer Project

## Brief

Utilizing data from Denver.gov, build a data pipeline which would allow users to
interact with large datasets effectively taking into account frequent data
updates. Requirements found at `de_task.md`

### Data

Non-emergency calls for help.
[311 Service](https://www.denvergov.org/media/gis/DataCatalog/311_service_data/csv/311_service_data_2015.csv)

Accident related data up to the present day.
[Traffic Data](https://www.denvergov.org/media/gis/DataCatalog/traffic_accidents/csv/traffic_accidents.csv)

### Technology

#### Apache Spark.

This is a perfect use-case for Spark for a few reasons:

1. Scale. Apache Spark is designed to handle enterprise levels of datasets.
2. Speed. Exploring your big data interactively is possible using
   implementations of Spark such as Pyspark.
3. Syntax. Spark (in particular PySpark) allows the user to use familiar
   Pandas-like syntax to query & transform datasets. In addition, SQL is
   available for users who prefer the declarative style of coding.
4. Support. Most major cloud providers have implementations available.

## Prerequisites

1. Apache Spark (Setup to follow)
2. git
3. Python 3.x
4. zsh
5. Optional (If following remote code)
    1. AWS Account
    2. AWS CLI Configured

## Setup

### Spark (Local)

In order to start using Apache Spark locally, you will need to install a local
copy. Fortunately, Python users have an easy way to get started.
Simply `pip install pyspark` in your environment will be enough to get a copy
installed locally. It is recommended to use a virtual environment for this step
of the process.

### Amazon Web Services (AWS)

If you would like to follow the remote code, you will need to have an active AWS
Account & preferably an IAM Administrator account set up. In addition, this
sample code uses AWS CLI to perform operations. The easiest option to get
accounts setup is to use `aws configure` to configure your settings.

### Directory

All code can be found under `src`. It is split by type of operation, with a
`local` and `remote` version of the same code. This is to showcase how you could
accomplish each task on your local computer or in the cloud.

Each version includes a directory for tasks 1-3 making it easy to understand the
logic flow matching the brief.

### Requirements.txt

Install required Python packages.

```shell
pip install -r requirements.txt
```

## Tasks

NOTE: All code expects the working directory set to the project. As mentioned
above, it is a good idea to create a virtual env to run project code.

NOTE2: The shell code assumes you are on the newer `zsh`.

### Task 1

The project assumes a daily cadence of data delivery and partitions the data
directories by the execution date. Shell was chosen for the ability to handle
large data downloads and simple integration with the AWS api. Alternatively,
python could be used to perform the same operation.

#### Local:

```shell
zsh src/local/task_1/dl_local.sh
```

This will download the datasets to your local machine under the
`/data/takehome-staging/exec_date` directory.

#### Remote:

The remote version of this code would instead of sending this data to our local
machine place itself into an S3 bucket with a similar partitioning scheme to
local. Under the `config.json` you can find the naming convention used by this
project.

```shell
zsh src/remote/task_1/stream_to_s3.sh
```

### Task 2

Making datasets queryable by Spark is straightforward. Although Spark can use
CSVs directly, it is more common to convert data files into an optimized format
such as Parquet. Subsequent loads of the data can take advantage of the format
for increased speed and reduced memory usage.

#### Local

Our local implementation uses Spark to convert the data files into parquet files
located within `data/takehome-process`.

```zsh
spark-submit --master "local[3]" src/local/task_2/create_datastore.py
```

Running the above code in your terminal will transform both files in parquet
format optimized for Spark. One note here is that `local[3]` will use 3 parallel
threads to process your application. Low powered machines may need to change
that setting.

#### Remote

The primary difference of the remote implementation is that we will be setting
up a small AWS EMR cluster to run our data jobs. The primary steps are:

1. Create additional buckets to hold logs and our pyspark scripts.
2. Setting up Key Pair for use with the project.
3. Create & setup the EMR cluster on AWS. This takes ~10 min to start up.
4. Submit the pyspark scripts to our running EMR cluster.

I've combined the setup steps (1-3) into a helper shell script. We'll keep the
EMR cluster running for now as it will be used in the final task.

```shell
zsh src/remote/task_2/setup/setup.sh
```

Once the setup is complete, you can go ahead and submit our jobs to the EMR
cluster. You can monitor the jobs under the AWS management console.

```shell
python3 src/remote/task_2/add_job_steps.py --job-type process
```

### Task 3

The final task is query our datasets and provide insights into the data. Our
analysis aims to answer these 4 questions:

1. Do the amount of traffic accidents vary over a given year? Do they show
   seasonality?
2. Does that also correlate with road conditions? What times of year are
   better/worse?
3. What geographical areas do 311 Service Calls occur in?
4. Do these translate to a similar number of traffic accidents?

#### Local

The local version of this report is straightforward. Saved to the
`src/local/task_3` directory is an example analysis of these questions using
Jupyter. The spark implementation here is using a local spark instance to run
the analysis code.

A pattern you will see in this notebook with pyspark is using spark SQL notation
to aggregate the large amount of data efficiently into tabular formats useful
for analysis. From there, you convert them to more data science friendly format
for general visualization. To launch, run the shell code below to open jupyter
lab. From there, you can click on the report in your browser and run the
analysis.

```shell
jupyter notebook src/local/task_3/analysis.ipynb
```

#### Remote

This version takes advantage of a utility
called [SparkMagic](https://github.com/jupyter-incubator/sparkmagic). It allows
the user to submit spark jobs from a local Jupyter notebook. The main advantage
is that you can take advantage of your local environment and avoid setting up a
bootstrap file for the cluster.

##### Setup

First, you will need to run the setup script.

```shell
zsh src/remote/task_3/setup/setup.sh
```

This will:

1. Create a key-value pair
2. Download, and install SparkMagic which will enable local jupyter notebooks to
   interact with the cluster
3. Enable port forwarding to connect the notebook to the EMR cluster

You will need to leave this terminal window running while interacting with the
jupyter notebook. In a **separate terminal**, you can run the command below to
open the analysis notebook.

```shell
jupyter notebook src/remote/task_3/analysis/spark_analysis.ipynb
```

### Conclusion - Project Completion

Included is a teardown script. Run this script to:

1. Stop running EMR clusters
2. Delete the take-home project buckets on S3.
3. Delete the key pair we created earlier.

```shell
zsh src/teardown.sh
```

### Potential Updates

#### Scheduling

In the case of repeated pulls of the data from the website, I would recommend a
scheduling service such as Apache Airflow. We avoided it for this project since
the data is relatively straightforward. The main benefit would be parameterizing
the jobs and reducing potential mistakes.

#### Analysis Framework[

Jupyter is great for sharing analyses between data analysts. However, as was
showcased here, it takes a bit of work to set up an appropriate environment. In
a company environment where resources would be shared, I could foresee using a
centralized service such as Databricks which combines computation with a
notebook environment making sharing relatively
painless. ](https://github.com/jupyter-incubator/sparkmagic)















