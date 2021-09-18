echo "Creating Persistent Jupyter Storage"
aws s3api create-bucket --acl public-read-write --bucket detakehomenotebooks --output text > setup.log

echo "Creating EMR Cluster"
aws emr create-cluster --applications Name=Spark Name=Zeppelin Name=JupyterHub \
 --service-role EMR_DefaultRole --enable-debugging --release-label emr-6.4.0 \
 --log-uri 's3n://takehome-logs/' \
 --name 'detakehome_process' \
 --configurations src/remote/task_3/setup/jupyter_emr_config.json \
 --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region us-east-1 \
 --instance-groups '[
  {
  "InstanceCount": 1,
  "EbsConfiguration": {
    "EbsBlockDeviceConfigs": [
      {
        "VolumeSpecification": {
          "SizeInGB": 32,
          "VolumeType": "gp2"
        },
        "VolumesPerInstance": 2
      }
    ]
  },
  "InstanceGroupType": "MASTER",
    "InstanceType": "m4.xlarge",
    "Name": "Master Instance Group"
  },
  {
    "InstanceCount": 2,
    "EbsConfiguration": {
      "EbsBlockDeviceConfigs": [
        {
          "VolumeSpecification": {
            "SizeInGB": 32,
            "VolumeType": "gp2"
          },
          "VolumesPerInstance": 2
        }
      ]
    },
    "InstanceGroupType": "CORE",
    "InstanceType": "m4.xlarge",
    "Name": "Core Instance Group"
  }
  ]' > cluster_profile.json

echo "Creating Jupyter Notebook Cluster"
aws emr create-cluster --applications Name=Hadoop Name=Spark Name=Livy Name=Hive Name=JupyterEnterpriseGateway \
 --tags 'creator=NOTEBOOK_CONSOLE'\
 --ec2-attributes \
 '{"InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-055768b121edc8916","EmrManagedSlaveSecurityGroup":"sg-0ca2488e92edbbc72","EmrManagedMasterSecurityGroup":"sg-07eaff368807d306a"}'\
 --service-role EMR_DefaultRole \
 --release-label emr-5.33.0 \
 --log-uri 's3n://aws-logs-320356124290-us-east-1/elasticmapreduce/' \
 --name 'NotebookCluster' \
 --instance-groups '[{"InstanceCount":1,"InstanceGroupType":"MASTER","InstanceType":"m3.xlarge","Name":"Master Instance Group"}]' \
 --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region us-east-1 > notebook.json


