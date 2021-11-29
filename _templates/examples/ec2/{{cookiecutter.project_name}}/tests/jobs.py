#!/usr/bin/env python

import boto3
from pprint import pprint
from .config import DATA_S3, ECR, COMPUTE_ENVIRONMENT, JOB_DEF_NAME, JOB_QUEUE_NAME, JOB_ROLE

client = boto3.client('batch')

response = client.list_jobs(
    jobQueue=JOB_QUEUE_NAME,
    jobStatus='RUNNABLE',
    maxResults=1000,
    # nextToken='string'
)

for job in response['jobSummaryList']:
    cancel_job_response = client.cancel_job(
        jobId=job['jobId'],
        reason='just testing'
    )