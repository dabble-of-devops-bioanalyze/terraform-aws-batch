data "aws_caller_identity" "current" {}

locals {
  # This is a cheap camelcase function
  id = replace(title(replace(module.this.id, "-", " ")), " ", "")
}

resource "aws_secretsmanager_secret" "batch" {
  name = module.this.id
  tags = module.this.tags
}

data "aws_iam_policy_document" "secrets_full_access" {
  statement {
    # sids cannot have -
    sid = "${local.id}SecretsFullAccess"

    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*",
      "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "secrets_full_access" {
  name   = "${module.this.id}-secrets-full-access"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets_full_access.json
  tags   = module.this.tags
}

output "aws_iam_policy_document-secrets_full_access" {
  value = data.aws_iam_policy_document.secrets_full_access
}

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
  count      = var.secrets_enabled ? 1 : 0
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

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

resource "aws_security_group" "batch" {
  count  = var.security_group_ids[0] == "" ? 1 : 0
  depends_on = [
    data.aws_vpc.selected
  ]
  name   = "${module.this.id}-aws_batch_compute_environment_security_group"
  tags   = module.this.tags
  vpc_id = var.vpc_id

  ingress {
    description      = "${module.this.id} Allow all traffic from vpc security group"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self = true
  }

  ingress {
    description      = "${module.this.id} EFS security group"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "${module.this.id} TLS security group"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "${module.this.id} SSH security group"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "${module.this.id} EFS security group"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
    security_group_ids = var.security_group_ids[0] == "" ? [aws_security_group.batch[0].id] : var.security_group_ids
}

module "ec2_batch_compute_environment" {
  count              = var.type == "EC2" || var.type == "SPOT" ? 1 : 0

  source = "./modules/aws-batch-ec2"
  type = var.type

  # security_group_ids = var.security_group_ids[0] == "" ? [aws_security_group.batch[0].id, aws_default_security_group.default] : var.security_group_ids
  security_group_ids = local.security_group_ids
  vpc_id = var.vpc_id
  max_vcpus = var.max_vcpus
  subnet_ids = var.subnet_ids

  ecs_instance_role = aws_iam_role.ecs_instance_role
  aws_iam_role_aws_batch_service_role = aws_iam_role.aws_batch_service_role
  aws_iam_role_policy_attachment_aws_batch_service_role = aws_iam_role_policy_attachment.aws_batch_service_role

  context = module.this.context
}

module "fargate_batch_compute_environment" {
  count              = var.type == "FARGATE" || var.type == "FARGATE_SPOT" ? 1 : 0

  source = "./modules/aws-batch-fargate"

  type = var.type

  # security_group_ids = var.security_group_ids[0] == "" ? ["${aws_security_group.batch[0].id}"] : var.security_group_ids
  # security_group_ids = var.security_group_ids[0] == "" ? [aws_security_group.batch[0].id, aws_default_security_group.default] : var.security_group_ids
  security_group_ids = local.security_group_ids
  vpc_id = var.vpc_id
  max_vcpus = var.max_vcpus
  subnet_ids = var.subnet_ids

  aws_iam_role_aws_batch_service_role = aws_iam_role.aws_batch_service_role
  aws_iam_role_policy_attachment_aws_batch_service_role = aws_iam_role_policy_attachment.aws_batch_service_role

  context = module.this.context
}

locals {
    aws_batch_compute_environment = var.type == "FARGATE" || var.type == "FARGATE_SPOT" ? module.fargate_batch_compute_environment[0].aws_batch_compute_environment : module.ec2_batch_compute_environment[0].aws_batch_compute_environment
}

resource "aws_batch_job_queue" "default_queue" {
  name     = "${module.this.id}-default-job-queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    local.aws_batch_compute_environment.arn,
  ]
  tags = module.this.tags
}
