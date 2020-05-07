#!/bin/bash
export HOME="/root"

fly_tarball="/usr/local/concourse/fly-assets/fly-linux-amd64.tgz"
mkdir -p $HOME/bin
tar -xzf $fly_tarball -C $HOME/bin/

$HOME/bin/fly --target ${target} login \
--concourse-url http://127.0.0.1:8080 \
--username ${concourse_username} \
--password ${concourse_password}

team_check=`$HOME/bin/fly -t aws-concourse teams | grep -v name | grep -v main`

if [ -z "$team_check" ]; then
    for team in $(ls $HOME/teams); do
        echo "--- Creating $team ---"
        /root/bin/fly -t ${target} set-team \
        --non-interactive \
        --team-name=$team \
        --config=/root/teams/$team/team.yml
    done
else
    echo "--- Updating $team ---"
    /root/bin/fly -t ${target} set-team \
    --non-interactive \
    --team-name=$team \
    --config=/root/teams/$team/team.yml
fi
