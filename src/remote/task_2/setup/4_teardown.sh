echo "Tearing down EMR cluster"
EMR_CLUSTER_ID=$(aws emr list-clusters --active --query 'Clusters[?Name==`detakehome_process`].Id' --output text)
aws emr terminate-clusters --cluster-ids $EMR_CLUSTER_ID >> tear_down.log