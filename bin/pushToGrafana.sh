#!/usr/bin/env bash

set -e

bindir=$(dirname $0)
dashdir=$(dirname $bindir)/dashboards

GRAFANA_URL=http://admin:admin@grafana.service.dc1.consul:3000

if [ $# -gt 0 ]; then
    case "$1" in
    http*) GRAFANA_URL="$1"; shift;;
    esac
fi

if [ $# = 0 ]; then
    set $dashdir/*.json
fi

for dashboard in "$@"; do
  echo "Uploading $dashboard"
  result=$($bindir/dashToCurl < $dashboard | curl -s -S -H "Content-Type: application/json" -d @- $GRAFANA_URL/api/dashboards/db)
  if [ $(echo "$result" |jq -r .status) != "success" ]; then
    echo "$result"
    # Stop on first error to avoid getting locked out due to too many failed password attempts.
    exit
  fi
done


