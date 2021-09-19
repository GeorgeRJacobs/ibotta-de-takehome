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