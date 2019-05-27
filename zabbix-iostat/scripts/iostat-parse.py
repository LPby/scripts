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
