#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

concourse_tarball="concourse-${concourse_version}-linux-amd64.tgz"
https_proxy="${https_proxy}" curl -s -L -O https://github.com/concourse/concourse/releases/download/v${concourse_version}/$concourse_tarball
tar -xzf $concourse_tarball -C /usr/local
rm $concourse_tarball

mkdir /etc/concourse

aws ssm get-parameter --with-decryption --name ${session_signing_key_ssm_id} | jq -r .Parameter.Value > /etc/concourse/session_signing_key
aws ssm get-parameter --with-decryption --name ${tsa_host_key_ssm_id} | jq -r .Parameter.Value > /etc/concourse/host_key
aws ssm get-parameter --with-decryption --name ${authorized_worker_keys_ssm_id} | jq -r .Parameter.Value > /etc/concourse/authorized_worker_keys

for cert in ${enterprise_github_certs}
do
    aws s3 cp $cert /etc/pki/ca-trust/source/anchors
done

update-ca-trust

if [[ "$(rpm -qf /sbin/init)" == upstart* ]];
then
    initctl start concourse-web
else
    systemctl enable concourse-web.service
    systemctl start concourse-web.service
fi
