#!/bin/bash

set -euxo pipefail

# Block external access to Concourse util correctly configured
iptables -I INPUT -p tcp --dport 8080 -j DROP
iptables -I INPUT -p tcp --dport 8080 -s 127.0.0.1 -j ACCEPT

export AWS_DEFAULT_REGION=${aws_default_region}
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
UUID=$(dbus-uuidgen | cut -c 1-8)
export HOSTNAME=${name}-$UUID

hostnamectl set-hostname $HOSTNAME
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME

cat <<EOF >> /etc/systemd/system/concourse-web.env
CONCOURSE_POSTGRES_PASSWORD=${database_password}
CONCOURSE_POSTGRES_USER=${database_user}
CONCOURSE_GITHUB_CLIENT_ID=${enterprise_github_oauth_client_id}
CONCOURSE_GITHUB_CLIENT_SECRET=${enterprise_github_oauth_client_secret}
CONCOURSE_USER=${concourse_user}
CONCOURSE_PASSWORD=${concourse_password}
CONCOURSE_ADD_LOCAL_USER=${concourse_user}:${concourse_password}
CONCOURSE_MAIN_TEAM_LOCAL_USER=${concourse_user}
EOF

mkdir /etc/concourse

cat > /etc/concourse/session_signing_key <<< ${session_signing_key}
cat > /etc/concourse/host_key <<< ${tsa_host_key}
cat > /etc/concourse/authorized_worker_keys <<< ${authorized_worker_keys}
cat > /etc/concourse/region <<< ${aws_default_region}

for cert in ${enterprise_github_certs}
do
    aws s3 cp $cert /etc/pki/ca-trust/source/anchors
done

update-ca-trust

touch /var/spool/cron/root
echo "*/3 * * * * /home/root/healthcheck.sh" >> /var/spool/cron/root
chmod 644 /var/spool/cron/root

if [[ "$(rpm -qf /sbin/init)" == upstart* ]];
then
    initctl start concourse-web
else
    systemctl enable concourse-web.service
    systemctl start concourse-web.service
fi
