#!/usr/bin/env bash

set -euxo pipefail

TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
REGION=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
curl -s -O https://s3.$REGION.amazonaws.com/amazoncloudwatch-agent-$REGION/assets/amazon-cloudwatch-agent.gpg
curl -s -O https://s3.$REGION.amazonaws.com/amazoncloudwatch-agent-$REGION/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm.sig
curl -s -O https://s3.$REGION.amazonaws.com/amazoncloudwatch-agent-$REGION/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

gpg --import amazon-cloudwatch-agent.gpg
gpg --verify amazon-cloudwatch-agent.rpm.sig amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${cloudwatch_agent_config_ssm_parameter} -s
