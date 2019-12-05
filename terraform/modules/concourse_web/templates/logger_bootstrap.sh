#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

# CloudWatch Agent

wget https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg
gpg --import amazon-cloudwatch-agent.gpg

wget -O cloudwatch.rpm.sig https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm.sig
wget -O cloudwatch.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

gpg --verify cloudwatch.rpm.sig cloudwatch.rpm

rpm -U ./cloudwatch.rpm

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${cloudwath_agent_config_ssm_parameter} -s
