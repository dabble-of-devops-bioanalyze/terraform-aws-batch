{
  "command": ["ls", "-la"],
  "image": "dabbleofdevops/nextflow-rnaseq-tutorial:latest",
  "resourceRequirements": [
    {"type": "MEMORY", "value": "8192"},
    {"type": "VCPU", "value": "4"}
  ],
  "environment": [{ "name": "VARNAME", "value": "VARVAL" }],
  "executionRoleArn": "${execution_role_arn}",
  "jobRoleArn": "${execution_role_arn}"
}