#!/usr/bin/python -u

import boto3
import time
import json
import sys
from slackclient import SlackClient

vault_name = 'crowdcontrol-ami-backups'
w_char = ['-', '\\', '|', '/']

boto3 = boto3.Session(profile_name='wfaw-10038')
client = boto3.client('glacier')

if len(sys.argv) > 1:
    job_id = sys.argv[1]
else:
    # create job
    init_job = client.initiate_job(
        vaultName=vault_name,
        jobParameters={'Type': 'inventory-retrieval'}
    )
    job_id = init_job['jobId']

# wait for job is complete
i = 0
sys.stderr.write("Wait while list is ready\n")
while True:
    if i%40 == 0:
        status = client.describe_job(vaultName=vault_name, jobId=job_id)
        if status['Completed']:
            break
    sys.stderr.write(w_char[i%4] + '\r')
    i += 1
    time.sleep(0.25)

# get job output
job_resp = client.get_job_output(vaultName=vault_name, jobId=job_id)
output = job_resp['body'].read()
archive_list = json.loads(output)['ArchiveList']
archive_list = json.dumps(archive_list, indent=2)
print archive_list
