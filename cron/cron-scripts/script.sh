#!/usr/bin/env bash
echo "$(date +"%d-%m-%y-%T"): Running Cron Job to wipe /data/output.json"
logrotate -f /cron-scripts/logrotate.conf -s /data/status -v
echo "$(date +"%d-%m-%y-%T"): File wiped"