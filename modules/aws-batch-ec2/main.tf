data "aws_ami" "ecs_latest" {
  most_recent = true
  owners      = ["amazon"]
  #if using plcuster
  #owners = ["247102896272"]

  filter {
    name   = "name"
    #    values = ["amzn-ami-*-amazon-ecs-optimized"]
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-eb"]
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
    instance_role = var.ecs_instance_profile.arn

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
    security_group_ids = var.security_group_ids
    subnets            = var.subnet_ids
    tags               = module.this.tags
    type               = "EC2"
  }

  service_role = var.aws_iam_role_aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [var.aws_iam_role_policy_attachment_aws_batch_service_role]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [
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

# Nextflow needs the aws cli installed
# https://www.nextflow.io/docs/latest/awscloud.html#aws-cli-installation
# do not use $HOME
sudo yum install -y bzip2 wget amazon-efs-utils
cd /home/ec2-user
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -f -p ./miniconda
./miniconda/bin/conda install -c conda-forge -y awscli
rm Miniconda3-latest-Linux-x86_64.sh

# https://docs.aws.amazon.com/batch/latest/userguide/efs-volumes.html
sudo systemctl enable --now amazon-ecs-volume-plugin

# Expand individual docker storage if container requires more than defaul 10GB
cloud-init-per once docker_options echo 'OPTIONS="$$${OPTIONS} --storage-opt dm.basesize=${var.docker_max_container_size}G"' >> /etc/sysconfig/docker

echo ECS_CLUSTER=default>>/etc/ecs/ecs.config
echo ECS_IMAGE_CLEANUP_INTERVAL=60m >> /etc/ecs/ecs.config
echo ECS_IMAGE_MINIMUM_CLEANUP_AGE=60m >> /etc/ecs/ecs.config

sudo systemctl restart docker || echo "unable to restart docker"
sudo start ecs || echo "unable to restart ecs"

## Extra user data
${var.additional_user_data}
TEMPLATE
}

# This is 100% stolen from the cloudposse/terraform-aws-autoscale-group
# https://github.com/cloudposse/terraform-aws-ec2-autoscale-group/blob/0.27.0/main.tf#L1

resource "aws_launch_template" "batch" {
  name_prefix = format("%s%s", module.this.id, module.this.delimiter)

  description = "Used by Batch Compute Environment ${module.this.id}"
  image_id    = var.custom_ami == "" ? data.aws_ami.ecs_latest.id : var.custom_ami
  # image_id    = var.use_pcluster_ami == true ? data.aws_ami.pcluster.id : data.aws_ami.ecs_latest.id

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
  # key_name = var.key_name
  key_name = var.ec2_key_pair != "" ? var.ec2_key_pair : null

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
