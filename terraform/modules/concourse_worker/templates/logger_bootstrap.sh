#!/usr/bin/env bash

set -euxo pipefail

export https_proxy="${https_proxy}"
curl -s -O https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg
curl -s -O https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm.sig
curl -s -O https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
unset https_proxy

gpg --import amazon-cloudwatch-agent.gpg
gpg --verify cloudwatch.rpm.sig cloudwatch.rpm
rpm -U ./cloudwatch.rpm

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${cloudwatch_agent_config_ssm_parameter} -s
