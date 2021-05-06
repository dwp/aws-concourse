#!/bin/bash
export HOME="/root"
export AWS_DEFAULT_REGION=${aws_default_region}
export CONCOURSE_USER=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_user)
export CONCOURSE_PASSWORD=$(aws secretsmanager get-secret-value --secret-id /concourse/dataworks/dataworks-secrets --query SecretBinary --output text | base64 -d | jq -r .concourse_password)

fly_tarball="/usr/local/concourse/fly-assets/fly-linux-amd64.tgz"
mkdir -p $HOME/bin
tar -xzf $fly_tarball -C $HOME/bin/

$HOME/bin/fly --target ${target} login \
--concourse-url http://127.0.0.1:8080 \
--username $CONCOURSE_USER \
--password $CONCOURSE_PASSWORD

team_check=`$HOME/bin/fly -t aws-concourse teams | grep -v name | grep -v main`

for team in $(ls $HOME/teams); do
    echo "--- $team ---"
    /root/bin/fly -t ${target} set-team \
    --non-interactive \
    --team-name=$team \
    --config=/root/teams/$team/team.yml
done

## At this point we've configured access to the teams, so the local user is no longer required.
sed -i '/CONCOURSE_USER/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_PASSWORD/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_ADD_LOCAL_USER/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_MAIN_TEAM_LOCAL_USER/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_USER/d' /etc/systemd/system/concourse-web.env
sed -i '/CONCOURSE_PASSWORD/d' /etc/systemd/system/concourse-web.env
sed -i '/CONCOURSE_ADD_LOCAL_USER/d' /etc/systemd/system/concourse-web.env
sed -i 's/\(CONCOURSE_MAIN_TEAM_LOCAL_USER\)=.*/\1=not_a_real_user/' /etc/systemd/system/concourse-web.env

# Restart the web service to load the new config
systemctl dameon-reload
systemctl stop concourse-web
sleep 1 ; killall -9 /usr/local/concourse/binconcourse || true ; sleep 1
systemctl start concourse-web

# Nwo that the local user is gone, open up the node
iptables -D INPUT -p tcp --dport 8080 -j DROP
iptables -D INPUT -p tcp --dport 8080 -s 127.0.0.1 -j ACCEPT

