DIR=$(egrep ^Include /etc/zabbix/zabbix_agentd.conf | cut -d= -f2 | cut -d / -f -4)
cat << EOF > "${DIR}/iostat.conf"
Timeout=30
UserParameter=iostat.discovery, python /etc/zabbix/scripts/iostat/iostat-discovery.py
UserParameter=iostat.collect, python /etc/zabbix/scripts/iostat/iostat-collect.py /tmp/iostat.json 8 || echo 1
UserParameter=iostat.metric[*], python /etc/zabbix/scripts/iostat/iostat-parse.py /tmp/iostat.json \$1 \$2
EOF

mkdir -p /etc/zabbix/scripts/iostat

cat << EOF > /etc/zabbix/scripts/iostat/iostat-collect.py
import sys
import re
import json
import subprocess


if len(sys.argv) != 3:
    print("FATAL: some parameters not specified")
    print("Usage: {} file timeout".format(sys.argv[0]))
    sys.exit(1)

tofile = sys.argv[1]
timeout = sys.argv[2]
data = []
stats = {}

process = subprocess.Popen(
    ["/usr/bin/iostat", "-d", "-x", "1", timeout],
    stderr=subprocess.STDOUT,
    stdout=subprocess.PIPE
)
stdout = process.communicate()[0].decode()
lines = stdout.split('\n\n')
flag = 0
for line in lines:
    if re.match("^Device", line):
        flag += 1
        if flag > 1:
            lines2 = line.split('\n')
            keys = lines2[0].split()
            for line2 in lines2[1:]:
                values = line2.split()
                data.append(dict(zip(keys, values)))
with open(tofile, 'w') as file:
    file.write(json.dumps(data, indent=2))
print("0")
EOF

cat << EOF > /etc/zabbix/scripts/iostat/iostat-discovery.py
import re
import json
import subprocess

data = {"data": []}
process = subprocess.Popen(
    ["/usr/bin/iostat", "-d"],
    stderr=subprocess.STDOUT,
    stdout=subprocess.PIPE
)
stdout = process.communicate()[0].decode()

flag = False
for line in stdout.split("\n"):
    if flag and line:
        data["data"].append({"{#HARDDISK}": line.split()[0]})
    if not flag and re.match(r"^Device", line):
        flag = True
print(json.dumps(data))
EOF

cat << EOF > /etc/zabbix/scripts/iostat/iostat-parse.py
import os
import sys
import json


if len(sys.argv) != 4:
    print("FATAL: some parameters not specified")
    print("Usage: {} fromfile device metric".format(sys.argv[0]))
    sys.exit(1)

fromfile = sys.argv[1]
device = sys.argv[2]
metric = sys.argv[3]
data = {}
metrics = []

if not os.path.isfile(fromfile):
    print("FATAL: datafile not found")
    sys.exit(1)

with open(fromfile, 'r') as file:
    data = json.load(file)

for d in data:
    if d['Device'] == device:
        metrics.append(d[metric])
print(sum([float(i.replace(',', '.')) for i in metrics]) / len(metrics))
EOF

service zabbix-agent restart

zabbix_agentd -t iostat.discovery