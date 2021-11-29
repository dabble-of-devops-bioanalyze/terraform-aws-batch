{
  "command": ["ls", "-la;", "echo 'hello'; sleep 60"],
  "image": "busybox",
  "resourceRequirements": [
      {"type": "MEMORY", "value": "2048"},
      {"type": "VCPU", "value": "1"}
  ],
  "environment": [{ "name": "VARNAME", "value": "VARVAL" }],
  "executionRoleArn": "${execution_role_arn}",
  "jobRoleArn": "${execution_role_arn}"
}