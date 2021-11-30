DATA_S3 = "${s3_bucket}"
JOB_S3 = DATA_S3


# These come from the terraform code in auto-deployment/terraform
ECR = "dabbleofdevops/nextflow-rnaseq-tutorial"
COMPUTE_ENVIRONMENT = "${compute_environment}"
JOB_DEF_NAME = "${job_def}"
JOB_QUEUE_NAME = "${job_queue}"
JOB_ROLE = "${execution_role_arn}"