{
  "command": ["ls", "-la"],
  "image": "public.ecr.aws/f8x0t1z3/nextflow-rnaseq-tutorial:latest",
  "resourceRequirements": [
    {"type": "MEMORY", "value": "8192"},
    {"type": "VCPU", "value": "4"}
  ],
  "environment": [{ "name": "VARNAME", "value": "VARVAL" }],
  "executionRoleArn": "${execution_role_arn}",
  "jobRoleArn": "${execution_role_arn}",
  "mountPoints": [
    {
      "containerPath": "/home/ec2-user/miniconda",
      "readOnly": true,
      "sourceVolume": "aws-cli"
    }
  ],
  "volumes": [
    {
      "host": {
        "sourcePath": "/home/ec2-user/miniconda"
      },
      "name": "aws-cli"
    }
  ]
}