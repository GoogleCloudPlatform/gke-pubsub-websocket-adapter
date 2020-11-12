#!/bin/bash
echo "Starting Server"
while true; do pulltop $@ > output.json ; done &
websocketd --port=8080 --devconsole tail -f output.json
