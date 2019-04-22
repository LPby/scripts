#!/usr/bin/env bash

FROMFILE=$1
DISK=$2
METRIC=$3

[[ $# -lt 3 ]] && { echo "FATAL: some parameters not specified"; exit 1; }
[[ -f "${FROMFILE}" ]] || { echo "FATAL: datafile not found"; exit 1; }

STATS=$(jq ".[].disk[] | select(.disk_device == \"${DISK}\") | .\"${METRIC}\"" ${FROMFILE})

if grep -q null <<<${STATS}; then
    echo ZBX_NOTSUPPORTED
else
    awk '
        BEGIN {
            sum=0.0;
            count=0;
        } 
        {
            sum=sum+$1;
            count=count+1;
        } 
        END {
            printf("%.2f\n", sum/count);
        }
    ' <<<${STATS}
fi
