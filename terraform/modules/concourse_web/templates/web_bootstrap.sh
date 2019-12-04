#!/bin/bash

set -e
set -u
set -x
set -o pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

curl -s -L -f -o ./concourse.tgz https://github.com/concourse/concourse/releases/download/v${concourse_version}/concourse-${concourse_version}-linux-amd64.tgz
tar -xzf ./concourse.tgz -C /usr/local

mkdir /etc/concourse

aws ssm get-parameter --with-decryption --name ${session_signing_key_ssm_id} | jq -r .Parameter.Value > /etc/concourse/session_signing_key
aws ssm get-parameter --with-decryption --name ${tsa_host_key_ssm_id} | jq -r .Parameter.Value > /etc/concourse/host_key
aws ssm get-parameter --with-decryption --name ${authorized_worker_keys_ssm_id} | jq -r .Parameter.Value > /etc/concourse/authorized_worker_keys

if [[ "$(rpm -qf /sbin/init)" == upstart* ]];
then
    initctl start concourse-web
else
    systemctl enable concourse-web.service
    systemctl start concourse-web.service
fi
