echo "Grabbing DNS"
EMR_CLUSTER_ID=$(aws emr list-clusters --cluster-states WAITING --query 'Clusters[?Name==`detakehome_analyze`].Id' --output text)
MASTER_DNS=$(aws emr describe-cluster --cluster-id $EMR_CLUSTER_ID --query 'Cluster.MasterPublicDnsName' --output text)

echo "Starting Port Forwarding. Keep terminal open until analysis is complete."
ssh -i DE_TAKEHOME_ANALYSIS.pem -N -L 8998:$MASTER_DNS:8998 hadoop@$MASTER_DNS
