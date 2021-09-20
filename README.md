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
3. config.json file
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

#### Amazon Web Services (AWS)

If you would like to follow the remote code, you will need to have an active AWS
Account & preferably an IAM Administrator account set up. In addition, this
sample code uses AWS CLI to perform operations.

The easiest option to get setup is to use `aws configure` to configure your
settings.

### Task 1

NOTE: All code expects the working directory set to the project. As mentioned
above, it is a good idea to create a virtual env to run project code.

NOTE2: The shell code assumes you are on the newer Z shell (Like a newer Mac).

Under the src directory, There will be 2 sets of files which you can run, local
& remote. Under each, I have a directory for each task. These showcase how I
would use these tools both in a local capacity and as well using cloud
technologies.

#### Local:

```shell
zsh src/task_1/local/dl_local.sh
```

This will download the datasets to your local machine under the
`/data/takehome-staging` directory.

#### Remote:

The remote version of this code would instead of sending this data to our local
machine place itself into an S3 bucket. Under the `config.json` you can find the
naming convention used by this project.

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
located at `data/takehome-process`.

```zsh
spark-submit --master "local[3]" src/task_2/local/create_datastore.py
```

Running the above code in your terminal will create both files in parquet format
optimized for Spark. One note here is that `local[3]` will use 3 parallel
threads to process your application.

#### Remote

The primary difference of the remote implementation is that we will be setting
up a small AWS EMR cluster to run our data jobs. The primary steps are:

1. Create & setup an EMR cluster on AWS. This takes ~10 min to start up.
2. Create additional buckets to hold logs and our pyspark scripts.
3. Submit the pyspark scripts to our running EMR cluster.
4. Shut down the EMR when the transforms are complete.

I've combined the setup steps (1-3) into a helper shell script.

```shell
zsh src/remote/task_2/setup/setup.sh
```

Once the setup is complete, you can go ahead and send our jobs to the EMR
cluster.

```shell
python3 src/remote/task_2/add_job_steps.py
```

You can check the status of the jobs under the UI in AWS Management Console.
Once complete, you can run the teardown shell to get rid of the EMR cluster.

```shell
zsh src/remote/task_2/setup/4_teardown.sh
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

The local version of this report is very straightforward. Saved to the
`src/local/task_3` directory is an example analysis of these questions using
Jupyter. The spark implementation here is using a local spark instance to run
the analysis code.

A pattern you see in this notebook with pyspark is using spark SQL notation to
aggregate the large amount of data efficiently into tabular formats useful for
analysis. From there, you convert them to more data science friendly format for
general visualization. To launch, run the shell code below to open jupyter lab.
From there, you can click on the report in your browser and run the analysis.

```shell
jupyter notebook src/local/task_3/analysis.ipynb
```

#### Remote

##### Introduction

There are many options for running an analysis against a given Spark cluster.
Given that we need to be able to scale our analyses in order to query against
data running on our S3 buckets as well as using a remote EMR clusters, I chose
to implement a jupyter notebook locally which sends commands to the cluster and
returns data and visualizations back to our local notebook.

The notebook uses a tool
called [Spark Magic](https://github.com/jupyter-incubator/sparkmagic) to
seamlessly send spark commands from a local notebook to a remote cluster. This
allows to very quickly scale up their analysis in the case they need to query a
remote source for data. Even better, you don't have to mirror your 
environment to the EMR cluster. Instead, you output data natively using 
SparkMagic and analyze the data locally where it makes sense to do so. If 
needed, you can also send data to the cluster to analyze on the beefy machines.

The main reason against such my approach is that the setup requires a bit of
work and technical knowledge from the user. The user is required to have SSH
access to a given EMR cluster. This is possible in certain organizations which
can sandbox these instances with the right permissions and with more technical
audiences. However, I could foresee less technically oriented analysts having
trouble.

Given that this project is meant to showcase querying big data, I felt this was
a necessary trade-off in order to show how a technical user might write
real-world production code and share analyses. An extension of this approach
would be Qubole's notebook interface. They make it very straightforward to run
jupyter notebooks in conjunction with Spark clusters running in Qubole's
ecosystem.

##### How to Run

First, you will need to run the setup script.

```shell
zsh src/remote/task_3/setup/setup.sh
```

This will:

1. Create a key-value pair
2. Start a new AWS EMR cluster loaded with Livy to enable remote analysis
3. Download, and install SparkMagic which will enable local jupyter notebooks to
   interact with the cluster
4. Enable port forwarding to connect the notebook to the EMR cluster

You will need to leave this terminal window running while interacting with the
jupyter notebook. In a separate window, you can run the command below to open
the analysis notebook.

```shell
jupyter notebook src/remote/task_3/analysis/spark_analysis.ipynb
```

The notebook has been updated to include spark magic related commands similar to
the 'local' copy.

### Conclusion

Included is a teardown script. Run this script to: 
1. Stop running EMR clusters
2. Delete takehome project buckets
3. 

```shell
zsh takedown.sh
```

#### Scheduling

Typically, if you are going to be pulling from an API more than once you will
want to have a scheduling service involved. This allows you to get the latest
data and reduce errors / data duplication. In this project, a simple extension
would be to use **AWS Lambda** functions. These serverless functions are ideal
for interacting with APIs without the hassle of setting up infrastructure. AN
even more robust scheduling service implementation would be an **Apache
Airflow** instance. Though you would need to set up a server, Airflow's benefit
is in the DAG oriented nature of building pipelines with support for jinja
templating.

#### Plotting

One potential problem with Pyspark is that it does not natively support plotting
RDD objects. A workaround which I demonstrate in the Jupyter notebook is to
convert aggregated datasets to Pandas dataframes and using the traditional
plotting packages. A potential upgrade would be to use something like Plotly. It
supports integration with Pyspark Dataframe. More info can be
found [here](https://plotly.com/python/v3/apache-spark/)















