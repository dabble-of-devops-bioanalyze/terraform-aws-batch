resource "aws_batch_compute_environment" "batch" {
  compute_environment_name = module.this.id

  compute_resources {
    max_vcpus = var.max_vcpus

    security_group_ids = var.security_group_ids
    subnets            = var.subnet_ids
    type               = var.type
  }

  service_role = var.aws_iam_role_aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [var.aws_iam_role_policy_attachment_aws_batch_service_role]
}
