# terraform {
#   required_version = ">= 0.12.2"

#   backend "s3" {
#     region         = "us-east-1"
#     bucket         = "bioanalyze-test-terraform-state"
#     key            = "bioanalyze-test-fargate-nf-rnaseq"
#     dynamodb_table = "bioanalyze-test-terraform-state-lock"
#     profile        = ""
#     role_arn       = ""
#     encrypt        = "true"
#   }
# }
