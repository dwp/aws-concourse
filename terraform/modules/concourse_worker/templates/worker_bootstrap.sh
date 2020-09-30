#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}

mkdir /etc/concourse

aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .tsa_host_pub_key > /etc/concourse/tsa_host_key.pub
aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .worker_key > /etc/concourse/worker_key

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
