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
