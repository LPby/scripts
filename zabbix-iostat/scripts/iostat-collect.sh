#!/usr/bin/env bash


TIMEOUT=$2
TOFILE=$1
IOSTAT="/usr/bin/iostat"

[[ $# -lt 2 ]] && { echo "FATAL: some parameters not specified"; exit 1; }

$IOSTAT -d -x -o JSON 1 $TIMEOUT | jq '.sysstat.hosts[0].statistics[1:]' > $TOFILE

echo 0
