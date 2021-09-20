echo "Creating Persistent Jupyter Storage"
aws s3api create-bucket --acl public-read-write --bucket detakehomenotebooks --output text > setup.log

echo "Installing JQ if not available"
brew list jq || brew install jq

echo "Opening Port Forwarding"
export EMR_MASTER_SG_ID=$(aws ec2 describe-security-groups | \
    jq -r '.SecurityGroups[] | select(.GroupName=="ElasticMapReduce-master").GroupId')

aws ec2 authorize-security-group-ingress \
    --group-id ${EMR_MASTER_SG_ID} \
    --protocol tcp \
    --port 22 \
    --cidr $(curl ipinfo.io/ip)/32 > port_forwarding.log

echo "Sending Requirements to EMR Cluster"
aws s3 cp reqs.sh s3://takehome-work/reqs.sh

ssh -i DE_TAKEHOME_ANALYSIS.pem -ND 8157 hadoop@ec2-3-234-244-44.compute-1.amazonaws.com


echo "Creating EMR Cluster w/ Jupyter Notebooks Access"
aws emr create-cluster \
--auto-scaling-role EMR_AutoScaling_DefaultRole \
--applications Name=Hadoop Name=Hive Name=Livy Name=Spark \
--ebs-root-volume-size 10 \
--ec2-attributes '{"KeyName":"DE_TAKEHOME_ANALYSIS","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-00ede872c7bd0533c","EmrManagedSlaveSecurityGroup":"sg-0ca2488e92edbbc72","EmrManagedMasterSecurityGroup":"sg-07eaff368807d306a"}' \
--service-role EMR_DefaultRole \
--enable-debugging \
--release-label emr-6.4.0 \
--log-uri 's3n://takehome-logs/' \
--name 'detakehome_analyze' \
--instance-groups '[{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"MASTER","InstanceType":"m5.xlarge","Name":"Master - 1"},{"InstanceCount":2,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"CORE","InstanceType":"m5.xlarge","Name":"Core - 2"}]' \
--scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
--region us-east-1 \
--bootstrap-actions Path=s3://takehome-work/reqs.sh,Name=AnalyticLibraries > cluster_profile.json

echo "Wait for Cluster Startup ~10 min"
EMR_CLUSTER_ID=$(aws emr list-clusters --cluster-states STARTING --query 'Clusters[?Name==`detakehome_analyze`].Id' --output text)
aws emr wait cluster-running --cluster-id $EMR_CLUSTER_ID




