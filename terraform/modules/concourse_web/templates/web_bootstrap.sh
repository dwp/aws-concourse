#!/bin/bash

set -euxo pipefail

# Block external access to Concourse util correctly configured
iptables -I INPUT -p tcp --dport 8080 -j DROP
iptables -I INPUT -p tcp --dport 8080 -s 127.0.0.1 -j ACCEPT

export AWS_DEFAULT_REGION=${aws_default_region}
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
export CONCOURSE_USER=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_user)
export CONCOURSE_PASSWORD=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_password)
export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
UUID=$(dbus-uuidgen | cut -c 1-8)
export HOSTNAME=${name}-$UUID

hostnamectl set-hostname $HOSTNAME
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME

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
