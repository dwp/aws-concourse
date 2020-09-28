#!/usr/bin/env bash

set -euxo pipefail

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${cloudwatch_agent_config_ssm_parameter} -s
