#!/bin/bash
for team in $(ls teams); do
    echo "--- ${team} ---"
    fly -t ${target} set-team \
    --non-interactive \
    --team-name=${team} \
    --config=teams/${team}/team.yml
done