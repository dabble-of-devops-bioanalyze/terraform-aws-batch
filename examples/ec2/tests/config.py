DATA_S3 = "stemaway-dev-nf-rnaseq-ckhtrqg88v"
JOB_S3 = DATA_S3

# These come from the terraform code in auto-deployment/terraform
ECR = "dabbleofdevops/nextflow-rnaseq-tutorial"
COMPUTE_ENVIRONMENT = "stemaway-dev-nf-rnaseq"
JOB_DEF_NAME = "stemaway-dev-nf-rnaseq"
DUMMY_JOB_DEF_NAME = "stemaway-dev-nf-rnaseq_test_batch_job_definition"
JOB_QUEUE_NAME = "stemaway-dev-nf-rnaseq-default-job-queue"
JOB_ROLE = "arn:aws:iam::858286506743:role/stemaway-dev-nf-rnaseq-batch_execution_role"