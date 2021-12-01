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
  type        = list(string)
}

variable "type" {
  description = "AWS Batch Compute Environment Type: must be one of EC2, SPOT, FARGATE or FARGATE_SPOT."
  type        = string
  default     = "EC2"
}

variable "secrets_enabled" {
  description = "Enable IAM Role for AWS Secrets Manager"
  type        = bool
  default     = false
}

###################################################
# EB2 Launch Data
###################################################

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
  default     = "100" # 100% of on demand price.  The module still requires this value when the compute type is not SPOT.
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
  default     = ["optimal"]
}

variable "max_vcpus" {
  description = "Max vCPUs.  Default 2 for m4.large."
  type        = string
  default     = 8
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
    ebs = object({
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
    market_type = string
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

variable "enable_batch_compute_environment" {
  type = bool
  default = true
  description = "Create a compute environment"
}
