data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "batch" {
  name = module.this.id
  tags = module.this.tags
}

locals {
  id = replace(title(replace(module.this.id, "-", " ")), " ", "")
}

data "aws_iam_policy_document" "secrets_full_access" {
  statement {
    # sids cannot have -
    sid       = "${local.id}SecretsFullAccess"

    actions = [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
    ]

    resources = [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*",
        "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/*"
     ]

    effect    = "Allow"
  }
}

resource "aws_iam_policy" "secrets_full_access" {
  name   = "${module.this.id}-secrets-full-access"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets_full_access.json
  tags = module.this.tags
}

output "aws_iam_policy_document-secrets_full_access" {
  value = data.aws_iam_policy_document.secrets_full_access
}
#resource "aws_iam_role" "batch_secrets_role" {
#  count    = var.secrets_enabled ? 1 : 0
#  name  = "${module.this.id}-batch_secrets_role"
#  tags  = module.this.tags
#
#  #TODO change this over to the policy document json
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "secretsmanager:GetSecretValue",
#        "kms:Decrypt"
#      ],
#      "Resource": [
#        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*",
#        "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/*"
#      ]
#    }
#  ]
#}
#EOF
#}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${module.this.id}-ecs_instance_role"
  tags = module.this.tags

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role" "batch_execution_role" {
  name = "${module.this.id}-batch_execution_role"
  tags = module.this.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "batch_execution_role" {
  role       = aws_iam_role.batch_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# if secrets are enabled add the secrets policy to the execution role
resource "aws_iam_role_policy_attachment" "batch_execution_attach_secrets" {
  count    = var.secrets_enabled ? 1 : 0
  role       = aws_iam_role.batch_execution_role.name
  policy_arn = aws_iam_policy.secrets_full_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "${module.this.id}-ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
  tags = module.this.tags
}

resource "aws_iam_role" "aws_batch_service_role" {
  name = "${module.this.id}-aws_batch_service_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "batch.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "aws_batch_full_access" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBatchFullAccess"
}

# If no security groups are supplied create one that allows all outgoing traffic
# And EFS

resource "aws_security_group" "batch" {
  count  = var.security_group_ids[0] == "" ? 1 : 0
  name   = "${module.this.id}-aws_batch_compute_environment_security_group"
  tags   = module.this.tags
  vpc_id = var.vpc_id

  ingress {
    description = "${module.this.id} EFS security group"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }

  ingress {
    description = "${module.this.id} SSH security group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ecs_latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_batch_compute_environment" "batch" {
  compute_environment_name = module.this.id

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    launch_template {
      launch_template_id = aws_launch_template.batch.id
      version            = aws_launch_template.batch.latest_version # 2020/02 - Explicit because $Latest uses $Default
    }

    ec2_key_pair  = var.ec2_key_pair != "" ? var.ec2_key_pair : null
    instance_type = var.instance_types
    max_vcpus     = var.max_vcpus
    min_vcpus     = var.min_vcpus

    # Use the supplied security group ids
    # Or just create one
    security_group_ids = var.security_group_ids[0] == "" ? ["${aws_security_group.batch[0].id}"] : var.security_group_ids
    subnets            = var.subnet_ids
    tags               = module.this.tags
    type               = "EC2"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      compute_resources[0].desired_vcpus
    ]
  }
}

data "template_file" "launch_template_user_data" {
  template = <<TEMPLATE
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Terraform script

# Install the AWS SSM agent to allow instance ingress
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# This needs to be added to use AWS Secrets Manager
# https://docs.aws.amazon.com/batch/latest/userguide/specifying-sensitive-data-secrets.html
echo "ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE=true" >> /etc/ecs/ecs.config

# Expand individual docker storage if container requires more than defaul 10GB
cloud-init-per once docker_options echo 'OPTIONS="$$${OPTIONS} --storage-opt dm.basesize=${var.docker_max_container_size}G"' >> /etc/sysconfig/docker
service docker restart

docker restart ecs-agent

${var.additional_user_data}
TEMPLATE
}

# This is 100% stolen from the cloudposse/terraform-aws-autoscale-group
# https://github.com/cloudposse/terraform-aws-ec2-autoscale-group/blob/0.27.0/main.tf#L1

resource "aws_launch_template" "batch" {
  name_prefix = format("%s%s", module.this.id, module.this.delimiter)

  description = "Used by Batch Compute Environment ${module.this.id}"
  image_id    = var.custom_ami == "" ? data.aws_ami.ecs_latest.id : var.custom_ami

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) == null ? [] : ["ebs"]
        content {
          delete_on_termination = lookup(block_device_mappings.value.ebs, "delete_on_termination", null)
          encrypted             = lookup(block_device_mappings.value.ebs, "encrypted", null)
          iops                  = lookup(block_device_mappings.value.ebs, "iops", null)
          kms_key_id            = lookup(block_device_mappings.value.ebs, "kms_key_id", null)
          snapshot_id           = lookup(block_device_mappings.value.ebs, "snapshot_id", null)
          volume_size           = lookup(block_device_mappings.value.ebs, "volume_size", null)
          volume_type           = lookup(block_device_mappings.value.ebs, "volume_type", null)
        }
      }
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = lookup(credit_specification.value, "cpu_credits", null)
    }
  }

  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = lookup(elastic_gpu_specifications.value, "type", null)
    }
  }

  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = lookup(instance_market_options.value, "market_type", null)

      dynamic "spot_options" {
        for_each = (instance_market_options.value.spot_options != null ?
        [instance_market_options.value.spot_options] : [])
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  # instance_type = var.instance_type
  key_name = var.key_name

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      tenancy           = lookup(placement.value, "tenancy", null)
    }
  }

  user_data = base64encode(data.template_file.launch_template_user_data.rendered)

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != "" ? [var.iam_instance_profile_name] : []
    content {
      name = iam_instance_profile.value
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/4570
  # network_interfaces {
  #   description                 = module.this.id
  #   device_index                = 0
  #   associate_public_ip_address = var.associate_public_ip_address
  #   delete_on_termination       = true
  #   security_groups             = var.security_group_ids
  # }

  metadata_options {
    http_endpoint               = (var.metadata_http_endpoint_enabled) ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = (var.metadata_http_tokens_required) ? "required" : "optional"
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications_resource_types

    content {
      resource_type = tag_specifications.value
      tags          = module.this.tags
    }
  }

  tags = module.this.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_batch_job_queue" "default_queue" {
  name     = "${module.this.id}-default-job-queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.batch.arn,
  ]
  tags = module.this.tags
}