#!/bin/bash

set -e
set -u
set -x
set -o pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

curl -s -L -f -o ./concourse.tgz https://github.com/concourse/concourse/releases/download/v${concourse_version}/concourse-${concourse_version}-linux-amd64.tgz
tar -xzf ./concourse.tgz -C /usr/local

mkdir /etc/concourse

aws ssm get-parameter --with-decryption --name ${tsa_host_pub_key_ssm_id} | jq -r .Parameter.Value > /etc/concourse/tsa_host_key.pub
aws ssm get-parameter --with-decryption --name ${worker_key_ssm_id} | jq -r .Parameter.Value > /etc/concourse/worker_key

if [[ "$(rpm -qf /sbin/init)" == upstart* ]];
then
    initctl start concourse-worker
else
    systemctl enable concourse-worker.service
    systemctl start concourse-worker.service
fi