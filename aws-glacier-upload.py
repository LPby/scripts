#!/usr/bin/python

import boto3
import os
import math
import sys
from botocore.utils import calculate_tree_hash
from pprint import pprint


max_retry = 10
vault_name = 'crowdcontrol-ami-backups'
part_size = 2 ** (20 + 6)  # 64M
print "Part size: " + str(part_size / 1024 / 1024) + "Mb"
filename = sys.argv[1]
description = sys.argv[2]

boto3 = boto3.Session(profile_name='wfaw-10038')
client = boto3.client('glacier')
upload = client.initiate_multipart_upload(
    vaultName=vault_name,
    archiveDescription=description,
    partSize=str(part_size)
)

file_len = os.path.getsize(filename)
file = open(filename, "rb")
for i in range(0, file_len, part_size):
    file.seek(i)
    data = file.read(part_size)
    data_range = "bytes {0}-{1}/*".format(i, i + len(data) - 1)
    retry = 0
    while True:
        print "Upload part {0}/{1} {2}:".format(
            (i / part_size) + 1,
            int(math.ceil(float(file_len) / part_size)),
            data_range
        ),
        try:
            upload_part = client.upload_multipart_part(
                vaultName=vault_name,
                uploadId=upload['uploadId'],
                range=data_range,
                body=data
            )
        except Exception as e:
            if retry == max_retry:
                print 'Max number of retry.'
                response = client.abort_multipart_upload(
                    vaultName=vault_name,
                    uploadId=upload['uploadId']
                )
                sys.exit(1)
            print e.message + ' Retry...'
            retry += 1
            continue
        print "OK"
        break

file.seek(0)
file_checksum = calculate_tree_hash(file)

upload_complete = client.complete_multipart_upload(
    vaultName=vault_name,
    uploadId=upload['uploadId'],
    archiveSize=str(file_len),
    checksum=file_checksum
)
file.close()
if upload_complete['ResponseMetadata']['HTTPStatusCode'] == '201':
    print "Upload complete"
    pprint(upload_complete)
else:
    print "Upload failed"
    sys.exit(1)


