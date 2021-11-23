output "id" {
  description = "ID of the created example"
  value       = module.this.enabled ? module.this.id : null
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_batch_job_queue" {
  value = aws_batch_job_queue.default_queue.name
}

output "aws_batch_compute_environment" {
  value = aws_batch_compute_environment.batch
}

output "aws_iam_role-batch_secrets_role" {
  value = aws_iam_role.batch_secrets_role
}

output "aws_secrets_manager_secret-batch" {
  value = aws_secretsmanager_secret.batch
}

output "aws_batch_ecs_instance_role" {
  value = aws_iam_instance_profile.ecs_instance_role
}

output "aws_batch_service_role" {
  value = aws_iam_role.aws_batch_service_role
}

output "aws_batch_secrets_role" {
  value = aws_iam_role.batch_secrets_role
}

output "aws_batch_execution_role" {
  value = aws_iam_role.batch_execution_role.name
}