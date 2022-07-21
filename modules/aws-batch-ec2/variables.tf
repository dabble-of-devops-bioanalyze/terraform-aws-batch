variable "region" {
  description = "AWS Region."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for the compute environment. Required."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets compute environment instances will be deployed in. Required."
  type        = list(any)
}

variable "ecs_instance_role" {
  description = "ecs instance role created by main module"
  type        = any
}
variable "ecs_instance_profile" {
  description = "ecs instance profile created by main module"
  type        = any
}

variable "aws_iam_role_aws_batch_service_role" {
  description = "AWS Batch IAM Service role"
  type        = any
}

variable "aws_iam_role_policy_attachment_aws_batch_service_role" {
  description = "Policy attachment for the AWS Batch Service Role"
  type        = any
}


variable "secrets_enabled" {
  description = "Enable IAM Role for AWS Secrets Manager"
  type        = bool
  default     = false
}

# type
variable "type" {
  description = "AWS Batch Compute Environment Type: must be one of EC2 or SPOT."
  type        = string
  default     = "EC2"
}

#######################################################################################
# AWS Batch Compute Environment - EC2
#######################################################################################

variable "additional_user_data" {
  description = "Additional User Data for the launch template.  Must include ==MYBOUNDARY== and Content-Type: entries."
  type        = string
  default     = ""
}

variable "ami_owners" {
  description = "List of owners for source ECS AMI."
  type        = list(any)
  default     = ["amazon"] # 591542846629
}

variable "bid_percentage" {
  description = "Integer of minimum percentage that a Spot Instance price must be when compared to on demand.  Example: A value of 20 would require the spot price be lower than 20% the current on demand price."
  type        = string
  default     = "100"
  # 100% of on demand price.  The module still requires this value when the compute type is not SPOT.
}

variable "custom_ami" {
  description = "Optional string for custom AMI.  If omitted, latest ECS AMI in the current region will be used."
  type        = string
  default     = ""
}

variable "docker_max_container_size" {
  description = "If docker_expand_volume is true, containers will allocate this amount of storage (GB) when launched."
  type        = number
  default     = 50
}

variable "ec2_key_pair" {
  description = "Optional keypair to connect to the instance with.  Consider SSM as an alternative."
  type        = string
  default     = ""
}

variable "instance_types" {
  description = "Optional list of instance types."
  type        = list(any)
  default     = [
    "c3",
    "c3.2xlarge",
    "c3.4xlarge",
    "c3.8xlarge",
    "c3.large",
    "c3.xlarge",
    "c4",
    "c4.2xlarge",
    "c4.4xlarge",
    "c4.8xlarge",
    "c4.large",
    "c4.xlarge",
    "c5",
    "c5.12xlarge",
    "c5.18xlarge",
    "c5.24xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "c5.9xlarge",
    "c5.large",
    "c5.metal",
    "c5.xlarge",
    "c5a",
    "c5a.12xlarge",
    "c5a.16xlarge",
    "c5a.24xlarge",
    "c5a.2xlarge",
    "c5a.4xlarge",
    "c5a.8xlarge",
    "c5a.large",
    "c5a.xlarge",
    "c5d",
    "c5d.12xlarge",
    "c5d.18xlarge",
    "c5d.24xlarge",
    "c5d.2xlarge",
    "c5d.4xlarge",
    "c5d.9xlarge",
    "c5d.large",
    "c5d.metal",
    "c5d.xlarge",
    "c5n",
    "c5n.18xlarge",
    "c5n.2xlarge",
    "c5n.4xlarge",
    "c5n.9xlarge",
    "c5n.large",
    "c5n.metal",
    "c5n.xlarge",
    "c6i",
    "c6i.12xlarge",
    "c6i.16xlarge",
    "c6i.24xlarge",
    "c6i.2xlarge",
    "c6i.32xlarge",
    "c6i.4xlarge",
    "c6i.8xlarge",
    "c6i.large",
    "c6i.metal",
    "c6i.xlarge",
    "m3",
    "m3.2xlarge",
    "m3.large",
    "m3.medium",
    "m3.xlarge",
    "m4",
    "m4.10xlarge",
    "m4.16xlarge",
    "m4.2xlarge",
    "m4.4xlarge",
    "m4.large",
    "m4.xlarge",
    "m5",
    "m5.12xlarge",
    "m5.16xlarge",
    "m5.24xlarge",
    "m5.2xlarge",
    "m5.4xlarge",
    "m5.8xlarge",
    "m5.large",
    "m5.metal",
    "m5.xlarge",
    "m5a",
    "m5a.12xlarge",
    "m5a.16xlarge",
    "m5a.24xlarge",
    "m5a.2xlarge",
    "m5a.4xlarge",
    "m5a.8xlarge",
    "m5a.large",
    "m5a.xlarge",
    "m5ad",
    "m5ad.12xlarge",
    "m5ad.16xlarge",
    "m5ad.24xlarge",
    "m5ad.2xlarge",
    "m5ad.4xlarge",
    "m5ad.8xlarge",
    "m5ad.large",
    "m5ad.xlarge",
    "m5d",
    "m5d.12xlarge",
    "m5d.16xlarge",
    "m5d.24xlarge",
    "m5d.2xlarge",
    "m5d.4xlarge",
    "m5d.8xlarge",
    "m5d.large",
    "m5d.metal",
    "m5d.xlarge",
    "m5zn",
    "m5zn.12xlarge",
    "m5zn.2xlarge",
    "m5zn.3xlarge",
    "m5zn.6xlarge",
    "m5zn.large",
    "m5zn.metal",
    "m5zn.xlarge",
    "m6i",
    "m6i.12xlarge",
    "m6i.16xlarge",
    "m6i.24xlarge",
    "m6i.2xlarge",
    "m6i.32xlarge",
    "m6i.4xlarge",
    "m6i.8xlarge",
    "m6i.large",
    "m6i.metal",
    "m6i.xlarge",
    "optimal",
    "r3",
    "r3.2xlarge",
    "r3.4xlarge",
    "r3.8xlarge",
    "r3.large",
    "r3.xlarge",
    "r4",
    "r4.16xlarge",
    "r4.2xlarge",
    "r4.4xlarge",
    "r4.8xlarge",
    "r4.large",
    "r4.xlarge",
    "r5",
    "r5.12xlarge",
    "r5.16xlarge",
    "r5.24xlarge",
    "r5.2xlarge",
    "r5.4xlarge",
    "r5.8xlarge",
    "r5.large",
    "r5.metal",
    "r5.xlarge",
    "r5a",
    "r5a.12xlarge",
    "r5a.16xlarge",
    "r5a.24xlarge",
    "r5a.2xlarge",
    "r5a.4xlarge",
    "r5a.8xlarge",
    "r5a.large",
    "r5a.xlarge",
    "r5ad",
    "r5ad.12xlarge",
    "r5ad.16xlarge",
    "r5ad.24xlarge",
    "r5ad.2xlarge",
    "r5ad.4xlarge",
    "r5ad.8xlarge",
    "r5ad.large",
    "r5ad.xlarge",
    "r5d",
    "r5d.12xlarge",
    "r5d.16xlarge",
    "r5d.24xlarge",
    "r5d.2xlarge",
    "r5d.4xlarge",
    "r5d.8xlarge",
    "r5d.large",
    "r5d.metal",
    "r5d.xlarge",
    "r5n",
    "r5n.12xlarge",
    "r5n.16xlarge",
    "r5n.24xlarge",
    "r5n.2xlarge",
    "r5n.4xlarge",
    "r5n.8xlarge",
    "r5n.large",
    "r5n.metal",
    "r5n.xlarge",
    "r6i",
    "r6i.12xlarge",
    "r6i.16xlarge",
    "r6i.24xlarge",
    "r6i.2xlarge",
    "r6i.32xlarge",
    "r6i.4xlarge",
    "r6i.8xlarge",
    "r6i.large",
    "r6i.metal",
    "r6i.xlarge",
  ]

}

variable "max_vcpus" {
  description = "Max vCPUs. This will declare how many instances you can have running at a given time. For example, setting this at 256 would allow for 16 tasks * 16 cpus each."
  type        = string
  default     = 640000
}

variable "min_vcpus" {
  description = "Minimum vCPUs.  > 0 causes instances to always be running."
  type        = string
  default     = 0
}

variable "security_group_ids" {
  description = "List of additional security groups to associate with cluster instances.  If empty, default security group will be added."
  default     = [""]
  type        = list(any)
}

##################################################################################
# Launch instance grabbed from
# https://github.com/cloudposse/terraform-aws-ec2-autoscale-group/blob/0.27.0/main.tf
##################################################################################

variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "Shutdown behavior for the instances. Can be `stop` or `terminate`"
  default     = "terminate"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "The IAM instance profile name to associate with launched instances"
  default     = ""
}

variable "key_name" {
  type        = string
  description = "The SSH key name that should be used for the instance"
  default     = ""
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable/disable detailed monitoring"
  default     = true
}

variable "ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"

  type = list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
    ebs          = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      volume_size           = number
      volume_type           = string
    })
  }))

  default = []
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instances"

  type = object({
    market_type  = string
    spot_options = object({
      block_duration_minutes         = number
      instance_interruption_behavior = string
      max_price                      = number
      spot_instance_type             = string
      valid_until                    = string
    })
  })

  default = null
}

variable "placement" {
  description = "The placement specifications of the instances"

  type = object({
    affinity          = string
    availability_zone = string
    group_name        = string
    host_id           = string
    tenancy           = string
  })

  default = null
}

variable "credit_specification" {
  description = "Customize the credit specification of the instances"

  type = object({
    cpu_credits = string
  })

  default = null
}

variable "elastic_gpu_specifications" {
  description = "Specifications of Elastic GPU to attach to the instances"

  type = object({
    type = string
  })

  default = null
}

variable "disable_api_termination" {
  type        = bool
  description = "If `true`, enables EC2 Instance Termination Protection"
  default     = false
}

variable "tag_specifications_resource_types" {
  type        = set(string)
  default     = ["instance", "volume"]
  description = "List of tag specification resource types to tag. Valid values are instance, volume, elastic-gpu and spot-instances-request."
}

variable "metadata_http_endpoint_enabled" {
  type        = bool
  default     = true
  description = "Set false to disable the Instance Metadata Service."
}

variable "metadata_http_tokens_required" {
  type        = bool
  default     = true
  description = "Set true to require IMDS session tokens, disabling Instance Metadata Service Version 1."
}

variable "metadata_http_put_response_hop_limit" {
  type        = number
  default     = 2
  description = <<-EOT
    The desired HTTP PUT response hop limit (between 1 and 64) for Instance Metadata Service requests.
    The default is `2` to support containerized workloads.
    EOT
}


###################################################
# Pcluster
###################################################

variable "pcluster_version" {
  type    = string
  default = "3.1.2"
}

variable "use_pcluster_ami" {
  type    = bool
  default = false
}
