#!/bin/bash
export HOME="/root"
export AWS_DEFAULT_REGION=${aws_default_region}

fly_tarball="/usr/local/concourse/fly-assets/fly-linux-amd64.tgz"
mkdir -p $HOME/bin
tar -xzf $fly_tarball -C $HOME/bin/

$HOME/bin/fly --target ${target} login \
--concourse-url http://127.0.0.1:8080 \
--username ${concourse_user} \
--password ${concourse_password}

team_check=`$HOME/bin/fly -t aws-concourse teams | grep -v name | grep -v main`

for team in $(ls $HOME/teams); do
    echo "--- $team ---"
    /root/bin/fly -t ${target} set-team \
    --non-interactive \
    --team-name=$team \
    --config=/root/teams/$team/team.yml
done

sed -i '/CONCOURSE_USER/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_PASSWORD/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_ADD_LOCAL_USER/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_MAIN_TEAM_LOCAL_USER/d' /etc/systemd/system/concourse-web.service
sed -i '/CONCOURSE_USER/d' /etc/systemd/system/concourse-web.env
sed -i '/CONCOURSE_PASSWORD/d' /etc/systemd/system/concourse-web.env
sed -i '/CONCOURSE_ADD_LOCAL_USER/d' /etc/systemd/system/concourse-web.env
sed -i '/CONCOURSE_MAIN_TEAM_LOCAL_USER/d' /etc/systemd/system/concourse-web.env

# Nwo that the local user is gone, open up the node
iptables -D INPUT -p tcp --dport 8080 -j DROP
iptables -D INPUT -p tcp --dport 8080 -s 127.0.0.1 -j ACCEPT
