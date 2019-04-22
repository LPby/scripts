#!/bin/bash

iostat -d -o JSON | jq '{data: .sysstat.hosts[0].statistics[].disk | map({"#HARDDISK": .disk_device})}'