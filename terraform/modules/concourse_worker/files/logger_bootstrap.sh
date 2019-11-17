#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

wget https://github.com/saymedia/journald-cloudwatch-logs/releases/download/v0.0.1/journald-cloudwatch-logs-linux.zip
unzip journald-cloudwatch-logs-linux.zip -d /opt

systemctl enable journald-cloudwatch-logs.service
systemctl start journald-cloudwatch-logs.service
