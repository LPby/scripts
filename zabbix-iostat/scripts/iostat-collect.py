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
