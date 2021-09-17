echo "Creating EMR Cluster"

aws emr create-cluster --applications Name=Spark Name=Zeppelin \
 --service-role EMR_DefaultRole --enable-debugging --release-label emr-5.33.0 \
 --log-uri 's3n://takehome-logs/' \
 --name 'detakehome' \
 --configurations '[{"Classification":"spark","Properties":{}}]' \
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
  ]' > cluster_profile.txt

echo "Cluster ID Profile Variable"
cat cluster_profile.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['ClusterId'])"

echo "Cluster ARN"
cat cluster_profile.txt | python3 -c "import sys, json; print(json.load(sys.stdin)['ClusterArn'])"


