#!/bin/bash

fly_tarball="fly-${concourse_version}-linux-amd64.tgz"
https_proxy="${https_proxy}" curl -s -L -O https://github.com/concourse/concourse/releases/download/v${concourse_version}/$fly_tarball
tar -xzf $fly_tarball -C /usr/local/bin/
rm -f $fly_tarball

fly --target ${concourse_setup.target} login \
--concourse-url http://127.0.0.1:8080 \
--username ${concourse_setup.username} \
--password ${concourse_setup.password}

team_check=`fly -t aws-concourse teams | grep -v name | grep -v main`

if [ -z $team_check ]; then
    for team in $(ls teams); do
        echo "--- ${team} ---"
        fly -t ${concourse_setup.target} set-team \
        --non-interactive \
        --team-name=${team} \
        --config=teams/${team}/team.yml
    done
else
    exit 0;
fi



