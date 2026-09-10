#!/bin/sh
MESSAGE="${1:-Hello from container}"

while true; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ${MESSAGE}"
  sleep 5
done
