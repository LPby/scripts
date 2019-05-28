import re
import json
import subprocess

data = {"data": []}
skippable = ("sr", "scd", "loop", "ram")

process = subprocess.Popen(
    ["/usr/bin/iostat", "-d"],
    stderr=subprocess.STDOUT,
    stdout=subprocess.PIPE
)
stdout = process.communicate()[0].decode()

flag = False
for line in stdout.split("\n"):
    if flag and line:
        device = line.split()[0]
        if not any(ignore in device for ignore in skippable):
            data["data"].append({"{#HARDDISK}": device})
    if not flag and re.match(r"^Device", line):
        flag = True
print(json.dumps(data, indent=2))
