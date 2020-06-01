#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

concourse_tarball="concourse-${concourse_version}-linux-amd64.tgz"
https_proxy="${https_proxy}" curl -s -L -O https://github.com/concourse/concourse/releases/download/v${concourse_version}/$concourse_tarball
tar -xzf $concourse_tarball -C /usr/local
rm $concourse_tarball

mkdir /etc/concourse

aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .session_signing_key > /etc/concourse/session_signing_key
aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .tsa_host_key > /etc/concourse/host_key
aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .authorized_worker_keys > /etc/concourse/authorized_worker_keys

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
