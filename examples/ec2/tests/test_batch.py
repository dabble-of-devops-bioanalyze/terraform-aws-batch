#!/usr/bin/env python

"""Tests for `terraform-aws-batch fargate` package."""

import pytest

from aws_batch_helpers.aws_batch_helpers import submit_batch_job, watch_job
from pprint import pprint
import time
import boto3
import logging
import pandas as pd
import s3fs
import json

logging.basicConfig(level=logging.INFO)
logging.getLogger("boto").setLevel(logging.CRITICAL)

from .config import (
    DATA_S3,
    ECR,
    COMPUTE_ENVIRONMENT,
    JOB_DEF_NAME,
    JOB_QUEUE_NAME,
    JOB_ROLE,
    SECRET_ARN,
    SECRET_NAME,
)

batch_client = boto3.client("batch")
log_client = boto3.client("logs")


def submit_batch_job_for_test(submit_data):
    logging.info("Submitting job")
    job_id, job_response = submit_batch_job(
        batch_client=batch_client, log_client=log_client, submit_job=submit_data
    )
    logging.info(f"Submitted job: {job_id}")
    logging.debug(job_response)

    logging.info("Watching job")
    status = watch_job(
        batch_client=batch_client, log_client=log_client, job_response=job_response
    )

    logging.info("Job Complete")

    job_response = batch_client.describe_jobs(jobs=[job_id])
    logging.info(f'Job complete with status: {job_response["jobs"][0]["status"]}')
    return job_response, status


def test_submit_job_batch():
    """Test submitting a job to batch"""

    command = ["bash", "-c", " ".join(["nextflow -h;", "sleep 60"])]
    job_name = "nextflow-demo"
    job_id = "job-{0}-{1}".format(job_name, int(time.time() * 1000))
    submit_data = {
        "jobName": job_id,
        "jobQueue": JOB_QUEUE_NAME,
        "jobDefinition": JOB_DEF_NAME,
        "parameters": {"S3_BUCKET": DATA_S3,},
        "containerOverrides": {"command": command},
    }
    job_response, status = submit_batch_job_for_test(submit_data)

    assert status == "SUCCEEDED", pprint(job_response)
    assert job_response["jobs"][0]["status"] == "SUCCEEDED"


def test_s3_access():
    """
    Test that job role has access to the s3 bucket
    For debugging check the job role that is in the job definition
    It should have read/write to any AWS resources it needs
    """
    fs = s3fs.S3FileSystem()
    iris = pd.read_csv(
        "https://raw.githubusercontent.com/mwaskom/seaborn-data/master/iris.csv"
    )
    logging.debug(pprint(iris.head()))

    logging.info("Testing the S3 Access credential roles")
    logging.info(f"Uploading iris.csv to: s3://{DATA_S3}/data/iris.csv")
    iris.to_csv(f"s3://{DATA_S3}/data/iris.csv")
    file_list = fs.ls(f"{DATA_S3}/data/")
    assert f"{DATA_S3}/data/iris.csv" in file_list
    logging.debug(file_list)

    command = [
        "bash",
        "-c",
        " ".join(
            [
                "pwd;",
                "ls -lah; "
                f"aws s3 cp s3://{DATA_S3}/data/iris.csv ./ && head iris.csv",
            ]
        ),
    ]
    job_name = "s3-access"
    job_id = "job-{0}-{1}".format(job_name, int(time.time() * 1000))
    submit_data = {
        "jobName": job_id,
        "jobQueue": JOB_QUEUE_NAME,
        "jobDefinition": JOB_DEF_NAME,
        "parameters": {"S3_BUCKET": DATA_S3,},
        "containerOverrides": {"command": command},
    }

    logging.info(f"Submitting job {job_name}")
    job_response, status = submit_batch_job_for_test(submit_data)

    assert status == "SUCCEEDED", pprint(job_response)
    assert job_response["jobs"][0]["status"] == "SUCCEEDED"

def test_miniconda_volume():
    """
    Test that our job definition mounts /home/ec2-user/miniconda from our host to the container
    """

    logging.info("Testing the S3 Access credential roles")
    logging.info(f"Uploading iris.csv to: s3://{DATA_S3}/data/iris.csv")

    command = [
        "bash",
        "-c",
        " ".join(
            [
                "ls -lah /home/ec2-user/miniconda;"
                "ls -lah /home/ec2-user/miniconda/bin/aws"
            ]
        ),
    ]
    job_name = "miniconda-access"
    job_id = "job-{0}-{1}".format(job_name, int(time.time() * 1000))
    submit_data = {
        "jobName": job_id,
        "jobQueue": JOB_QUEUE_NAME,
        "jobDefinition": JOB_DEF_NAME,
        "containerOverrides": {"command": command},
    }

    logging.info(f"Submitting job {job_name}")
    job_response, status = submit_batch_job_for_test(submit_data)

    assert status == "SUCCEEDED", pprint(job_response)
    assert job_response["jobs"][0]["status"] == "SUCCEEDED"

# def test_secrets():
#     """
#     Test our secrets role
#     https://docs.aws.amazon.com/batch/latest/userguide/specifying-sensitive-data-secrets.html
#     """
#     secrets_client = boto3.client("secretsmanager")
#     response = secrets_client.put_secret_value(
#         SecretId=SECRET_ARN,
#         SecretString=json.dumps({"HELLO": "WORLD"}),
#     )
#     secrets = [
#                 {
#                     "name": "HELLO",
#                     "valueFrom": f"{SECRET_ARN}:HELLO::",
#                 }
#             ]

#     command = ["bash", "-c", " ".join(["echo ${HELLO}", "sleep 60"])]
#     job_name = "secret-access"
#     job_id = "job-{0}-{1}".format(job_name, int(time.time() * 1000))
#     submit_data = {
#         "jobName": job_id,
#         "jobQueue": JOB_QUEUE_NAME,
#         "jobDefinition": JOB_DEF_NAME,
#         "parameters": {"S3_BUCKET": DATA_S3,},
#         "containerOverrides": {"command": command, "secrets": secrets},
#     }

#     job_response, status = submit_batch_job_for_test(submit_data)

#     assert status == "SUCCEEDED", pprint(job_response)
#     assert job_response["jobs"][0]["status"] == "SUCCEEDED"