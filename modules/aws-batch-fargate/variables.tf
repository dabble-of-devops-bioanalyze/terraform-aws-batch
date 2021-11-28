variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets compute environment instances will be deployed in."
  type        = list(any)
}

variable "max_vcpus" {
  description = "Max vCPUs.  Default 2 for m4.large."
  type        = string
  default     = 8
}

variable "security_group_ids" {
  description = "List of additional security groups to associate with cluster instances.  If empty, default security group will be added."
  default     = [""]
  type        = list(any)
}

variable "aws_iam_role_aws_batch_service_role" {
  description = "AWS Batch IAM Service role"
  type        = any
}

variable "aws_iam_role_policy_attachment_aws_batch_service_role" {
  description = "Policy attachment for the AWS Batch Service Role"
  type        = any
}

variable "type" {
  description = "AWS Batch Compute Environment Type: must be one of FARGATE or FARGATE_SPOT."
  type        = string
  default     = "FARGATE"
}
