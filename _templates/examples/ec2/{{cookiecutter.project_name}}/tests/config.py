DATA_S3 = "stemaway-fargate-nf-rnaseq-5jbrnartzo"
JOB_S3 = DATA_S3

# These come from the terraform code in auto-deployment/terraform
ECR = "dabbleofdevops/nextflow-rnaseq-tutorial"
COMPUTE_ENVIRONMENT = "stemaway-fargate-nf-rnaseq"
JOB_DEF_NAME = "stemaway-fargate-nf-rnaseq"
DUMMY_JOB_DEF_NAME = "stemaway-fargate-nf-rnaseq_test_batch_job_definition"
JOB_QUEUE_NAME = "stemaway-fargate-nf-rnaseq-default-job-queue"
JOB_ROLE = "arn:aws:iam::018835827632:role/stemaway-fargate-nf-rnaseq-batch_execution_role"