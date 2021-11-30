DATA_S3 = "bioanalyze-fargate-test-nf-rnaseq-5jbrnartzo"
JOB_S3 = DATA_S3

# These come from the terraform code in auto-deployment/terraform
ECR = "dabbleofdevops/nextflow-rnaseq-tutorial"
COMPUTE_ENVIRONMENT = "bioanalyze-fargate-test-nf-rnaseq"
JOB_DEF_NAME = "bioanalyze-fargate-test-nf-rnaseq"
DUMMY_JOB_DEF_NAME = "bioanalyze-fargate-test-nf-rnaseq_test_batch_job_definition"
JOB_QUEUE_NAME = "bioanalyze-fargate-test-nf-rnaseq-default-job-queue"
JOB_ROLE = "arn:aws:iam::018835827632:role/bioanalyze-fargate-test-nf-rnaseq-batch_execution_role"