#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

concourse_tarball="concourse-${concourse_version}-linux-amd64.tgz"
https_proxy="${https_proxy}" curl -s -L -O https://github.com/concourse/concourse/releases/download/v${concourse_version}/$concourse_tarball
tar -xzf $concourse_tarball -C /usr/local
rm $concourse_tarball

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
