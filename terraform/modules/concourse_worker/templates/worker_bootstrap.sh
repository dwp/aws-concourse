#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

concourse_tarball="concourse-${concourse_version}-linux-amd64.tgz"
https_proxy="${https_proxy}" curl -s -L -O https://github.com/concourse/concourse/releases/download/v${concourse_version}/$concourse_tarball
tar -xzf $concourse_tarball -C /usr/local
rm $concourse_tarball

mkdir /etc/concourse

aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -D | jq -r .tsa_host_key > /etc/concourse/tsa_host_key.pub
aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -D | jq -r .worker_key > /etc/concourse/worker_key

for cert in ${enterprise_github_certs}
do
    aws s3 cp $cert /etc/pki/ca-trust/source/anchors
done

update-ca-trust
# some check-resource containers seem to want to only check ca-certificates.crt
cp /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt

touch /var/spool/cron/root
echo "*/3 * * * * /home/root/healthcheck.sh" >> /var/spool/cron/root
chmod 644 /var/spool/cron/root

if [[ "$(rpm -qf /sbin/init)" == upstart* ]];
then
    initctl start concourse-worker
else
    systemctl enable concourse-worker.service
    systemctl start concourse-worker.service
fi
