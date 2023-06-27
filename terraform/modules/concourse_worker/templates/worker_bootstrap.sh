#!/bin/bash

set -euxo pipefail

export AWS_DEFAULT_REGION=${aws_default_region}
UUID=$(dbus-uuidgen | cut -c 1-8)
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
export AWS_AZ=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep availabilityZone|awk -F\" '{print $4}')
export HOSTNAME=${name}-$AWS_AZ-$UUID

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

lvextend -l 100%FREE /dev/rootvg/rootvol
xfs_growfs /dev/mapper/rootvg-rootvol

echo "Setup hcs pre-requisites"
mkdir /opt/concourse
mkdir /var/log/concourse
chmod u+x /opt/concourse/config_hcs.sh
/opt/concourse/config_hcs.sh "${hcs_environment}" "${proxy_host}" "${proxy_port}" "${tanium_server_1}" "${tanium_server_2}" "${tanium_env}" "${tanium_port}" "${tanium_log_level}" "${install_tenable}" "${install_trend}" "${install_tanium}" "${tenantid}" "${token}" "${policyid}" "${tenant}"


hostnamectl set-hostname $HOSTNAME
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME


mkdir /etc/concourse

cat > /etc/concourse/tsa_host_key.pub <<< ${tsa_host_pub_key}
cat > /etc/concourse/worker_key <<< ${worker_key}

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
