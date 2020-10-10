#!/bin/bash
echo "Starting Server"
while true; do node /project/pulltop/pulltop.js $@ > output.json ; done &
websocketd --port=8080 --devconsole tail -f output.json
