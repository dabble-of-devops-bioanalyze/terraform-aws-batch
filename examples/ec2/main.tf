provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = "2.64.0"
  name = module.this.name
  cidr = "10.0.0.0/16"
  # azs = data.aws_availability_zones.available.names
  azs = ["us-east-1a"]
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  "10.0.3.0/24"]
  public_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
  "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = module.this.tags
}

# output "vpc" {
#   value = module.vpc
# }

locals {
  # create vpc and subnets
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = local.subnet_ids
}

module "batch" {
  depends_on = [
    module.vpc,
  ]

  # TODO
  # source  = "dabble-of-devops-bioanalyze/batch/aws"
  # version >= "1.13.0"
  source = "../../terraform-recipes/terraform-aws-batch"
  # insert the 17 required variables here
  region = var.region
  vpc_id = local.vpc_id

  subnet_ids      = local.subnet_ids
  max_vcpus       = var.max_vcpus
  type            = var.type
  secrets_enabled = var.secrets_enabled
  ec2_key_pair = var.ec2_key_pair

  context = module.this.context
}


resource "random_string" "s3" {
  length           = 10
  special          = true
  override_special = "-"
  upper            = false
  number           = true
}

resource "aws_s3_bucket" "workflow" {
  bucket = "${module.this.id}-${random_string.s3.id}"
  tags = module.this.tags
}

resource "aws_s3_bucket_acl" "workflow" {
  bucket = aws_s3_bucket.workflow.id
  acl    = "private"
}

output "batch" {
  value = module.batch
}

output "s3_bucket" {
  # value = module.s3_bucket.bucket_id
  value = aws_s3_bucket.workflow.id
}


locals {
  # cheap camelcase function
  id = replace(title(replace(module.this.id, "-", " ")), " ", "")
  s3_bucket_id = aws_s3_bucket.workflow.id

}
data "aws_iam_policy_document" "s3_full_access" {
  statement {
    # sids cannot have -
    sid       = "${local.id}S3FullAccess"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.s3_bucket_id}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation",
      "s3:AbortMultipartUpload"
    ]
  }
}

data "aws_iam_policy_document" "s3_base_access" {
  statement {
    # sids cannot have -
    sid = "${local.id}S3BaseAccess"

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]

    resources = ["arn:aws:s3:::${local.s3_bucket_id}"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "s3_full_access" {
  name   = "${module.this.id}-s3-full-access"
  path   = "/"
  policy = data.aws_iam_policy_document.s3_full_access.json
}

resource "aws_iam_policy" "s3_base_access" {
  name   = "${module.this.id}-s3-base-access"
  path   = "/"
  policy = data.aws_iam_policy_document.s3_base_access.json
}

resource "aws_iam_role_policy_attachment" "batch_execution_role_s3_base_access" {
  role       = module.batch.aws_batch_execution_role.name
  policy_arn = aws_iam_policy.s3_base_access.arn
}

resource "aws_iam_role_policy_attachment" "batch_execution_role_s3_full_access" {
  role       = module.batch.aws_batch_execution_role.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}

data "template_file" "container_properties" {
  depends_on = [
    module.batch,
    aws_s3_bucket.workflow,
    # module.s3_bucket,
  ]
  template = file("${path.module}/container-properties.json.tpl")
  vars = {
    execution_role_arn = module.batch.aws_batch_execution_role.arn
  }
}

resource "local_file" "container_properties" {
  depends_on = [
    data.template_file.container_properties
  ]
  content  = data.template_file.container_properties.rendered
  filename = "${path.module}/container-properties.json"
}

resource "aws_batch_job_definition" "rnaseq" {
  name                  = module.this.id
  type                  = "container"
  container_properties  = data.template_file.container_properties.rendered
  platform_capabilities = [var.type]
  propagate_tags        = true
  tags                  = module.this.tags
}

resource "local_file" "nextflow_config" {
  depends_on = [
    module.batch,
    aws_s3_bucket.workflow,
    # module.s3_bucket,
    aws_batch_job_definition.rnaseq
  ]
  content  = <<EOF
  profiles {
    standard {

    }

    batch {
      process.container = 'job-definition://${aws_batch_job_definition.rnaseq.name}'

      process.executor = 'awsbatch'
      process.queue = '${module.batch.aws_batch_job_queue}'
      workDir = 's3://${local.s3_bucket_id}/work'

      aws.region = '${var.region}'
    }

  }
  EOF
  filename = "${path.module}/nextflow.config"
}

data "template_file" "pytest" {
  depends_on = [
    module.batch,
    aws_s3_bucket.workflow,
    # module.s3_bucket,
    local_file.nextflow_config
  ]
  template = file("${path.module}/tests/config.py.tpl")
  vars = {
    # s3_bucket           = module.s3_bucket.bucket_id
    s3_bucket           = local.s3_bucket_id
    job_queue           = module.batch.aws_batch_job_queue
    job_def             = aws_batch_job_definition.rnaseq.name
    job_role            = module.batch.aws_batch_execution_role.arn
    compute_environment = module.this.id
    execution_role_arn  = module.batch.aws_batch_execution_role.arn
    secret_name         = module.batch.aws_secrets_manager_secret-batch.name
    secret_arn          = module.batch.aws_secrets_manager_secret-batch.arn
  }
}

resource "local_file" "pytest" {
  depends_on = [
    data.template_file.pytest
  ]
  content  = data.template_file.pytest.rendered
  filename = "${path.module}/tests/config.py"
}

output "nextflow_config" {
  value     = local_file.nextflow_config
  sensitive = true
}

resource "null_resource" "pytest" {
  count = var.run_tests ? 1 : 0
  depends_on = [
    module.batch,
    # module.s3_bucket,
    aws_s3_bucket.workflow,
    aws_iam_policy.s3_full_access,
    aws_iam_role_policy_attachment.batch_execution_role_s3_base_access,
    aws_iam_role_policy_attachment.batch_execution_role_s3_full_access,
    aws_batch_job_definition.rnaseq,
    local_file.pytest,
    local_file.nextflow_config,
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "pip install -r tests/requirements.txt; python -m pytest -s --log-cli-level=INFO tests/test_batch.py"
    environment = {
      AWS_REGION         = var.region
      AWS_DEFAULT_REGION = var.region
      LOG_LEVEL          = "INFO"
    }
  }
}
