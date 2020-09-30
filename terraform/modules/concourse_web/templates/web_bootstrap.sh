#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}
export CONCOURSE_USER=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_user)
export CONCOURSE_PASSWORD=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_password)

cat <<EOF >> /etc/systemd/system/concourse-web.env
CONCOURSE_POSTGRES_PASSWORD=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .database_password)
CONCOURSE_POSTGRES_USER=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .database_user)
CONCOURSE_USER=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_user)
CONCOURSE_PASSWORD=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_password)
CONCOURSE_ADD_LOCAL_USER=$CONCOURSE_USER:$CONCOURSE_PASSWORD
CONCOURSE_GITHUB_CLIENT_ID=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .enterprise_github_oauth_client_id)
CONCOURSE_GITHUB_CLIENT_SECRET=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .enterprise_github_oauth_client_secret)
CONCOURSE_MAIN_TEAM_LOCAL_USER=$CONCOURSE_USER
EOF

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
