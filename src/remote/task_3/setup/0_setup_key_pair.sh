#!/bin/zsh

echo "Creating DE Takehome Key Pair - Will be deleted afterwards"
aws ec2 create-key-pair \
    --key-name DE_TAKEHOME_ANALYSIS \
    --key-type rsa \
    --query "KeyMaterial" \
    --output text > DE_TAKEHOME_ANALYSIS.pem
chmod 400 DE_TAKEHOME_ANALYSIS.pem