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