<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_batch_compute_environment"></a> [ec2\_batch\_compute\_environment](#module\_ec2\_batch\_compute\_environment) | ./modules/aws-batch-ec2 | n/a |
| <a name="module_fargate_batch_compute_environment"></a> [fargate\_batch\_compute\_environment](#module\_fargate\_batch\_compute\_environment) | ./modules/aws-batch-fargate | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_batch_job_queue.default_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_iam_instance_profile.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.secrets_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.aws_batch_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.batch_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_batch_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.aws_batch_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.batch_execution_attach_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.batch_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_security_group.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.secrets_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_additional_user_data"></a> [additional\_user\_data](#input\_additional\_user\_data) | Additional User Data for the launch template.  Must include ==MYBOUNDARY== and Content-Type: entries. | `string` | `""` | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | List of owners for source ECS AMI. | `list(any)` | <pre>[<br>  "amazon"<br>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_bid_percentage"></a> [bid\_percentage](#input\_bid\_percentage) | Integer of minimum percentage that a Spot Instance price must be when compared to on demand.  Example: A value of 20 would require the spot price be lower than 20% the current on demand price. | `string` | `"100"` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | <pre>list(object({<br>    device_name  = string<br>    no_device    = bool<br>    virtual_name = string<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = number<br>      kms_key_id            = string<br>      snapshot_id           = string<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | Customize the credit specification of the instances | <pre>object({<br>    cpu_credits = string<br>  })</pre> | `null` | no |
| <a name="input_custom_ami"></a> [custom\_ami](#input\_custom\_ami) | Optional string for custom AMI.  If omitted, latest ECS AMI in the current region will be used. | `string` | `""` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If `true`, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_docker_max_container_size"></a> [docker\_max\_container\_size](#input\_docker\_max\_container\_size) | If docker\_expand\_volume is true, containers will allocate this amount of storage (GB) when launched. | `number` | `50` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_ec2_key_pair"></a> [ec2\_key\_pair](#input\_ec2\_key\_pair) | Optional keypair to connect to the instance with.  Consider SSM as an alternative. | `string` | `""` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | Specifications of Elastic GPU to attach to the instances | <pre>object({<br>    type = string<br>  })</pre> | `null` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable/disable detailed monitoring | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | The IAM instance profile name to associate with launched instances | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instances. Can be `stop` or `terminate` | `string` | `"terminate"` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | The market (purchasing) option for the instances | <pre>object({<br>    market_type = string<br>    spot_options = object({<br>      block_duration_minutes         = number<br>      instance_interruption_behavior = string<br>      max_price                      = number<br>      spot_instance_type             = string<br>      valid_until                    = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Optional list of instance types. | `list(any)` | <pre>[<br>  "optimal"<br>]</pre> | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The SSH key name that should be used for the instance | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_max_vcpus"></a> [max\_vcpus](#input\_max\_vcpus) | Max vCPUs.  Default 2 for m4.large. | `string` | `8` | no |
| <a name="input_metadata_http_endpoint_enabled"></a> [metadata\_http\_endpoint\_enabled](#input\_metadata\_http\_endpoint\_enabled) | Set false to disable the Instance Metadata Service. | `bool` | `true` | no |
| <a name="input_metadata_http_put_response_hop_limit"></a> [metadata\_http\_put\_response\_hop\_limit](#input\_metadata\_http\_put\_response\_hop\_limit) | The desired HTTP PUT response hop limit (between 1 and 64) for Instance Metadata Service requests.<br>The default is `2` to support containerized workloads. | `number` | `2` | no |
| <a name="input_metadata_http_tokens_required"></a> [metadata\_http\_tokens\_required](#input\_metadata\_http\_tokens\_required) | Set true to require IMDS session tokens, disabling Instance Metadata Service Version 1. | `bool` | `true` | no |
| <a name="input_min_vcpus"></a> [min\_vcpus](#input\_min\_vcpus) | Minimum vCPUs.  > 0 causes instances to always be running. | `string` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | The placement specifications of the instances | <pre>object({<br>    affinity          = string<br>    availability_zone = string<br>    group_name        = string<br>    host_id           = string<br>    tenancy           = string<br>  })</pre> | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_secrets_enabled"></a> [secrets\_enabled](#input\_secrets\_enabled) | Enable IAM Role for AWS Secrets Manager | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of additional security groups to associate with cluster instances.  If empty, default security group will be added. | `list(any)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets compute environment instances will be deployed in. | `list(string)` | n/a | yes |
| <a name="input_tag_specifications_resource_types"></a> [tag\_specifications\_resource\_types](#input\_tag\_specifications\_resource\_types) | List of tag specification resource types to tag. Valid values are instance, volume, elastic-gpu and spot-instances-request. | `set(string)` | <pre>[<br>  "instance",<br>  "volume"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | AWS Batch Compute Environment Type: must be one of EC2, SPOT, FARGATE or FARGATE\_SPOT. | `string` | `"EC2"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_aws_batch_compute_environment"></a> [aws\_batch\_compute\_environment](#output\_aws\_batch\_compute\_environment) | n/a |
| <a name="output_aws_batch_ecs_instance_role"></a> [aws\_batch\_ecs\_instance\_role](#output\_aws\_batch\_ecs\_instance\_role) | n/a |
| <a name="output_aws_batch_execution_role"></a> [aws\_batch\_execution\_role](#output\_aws\_batch\_execution\_role) | n/a |
| <a name="output_aws_batch_job_queue"></a> [aws\_batch\_job\_queue](#output\_aws\_batch\_job\_queue) | n/a |
| <a name="output_aws_batch_service_role"></a> [aws\_batch\_service\_role](#output\_aws\_batch\_service\_role) | n/a |
| <a name="output_aws_iam_policy_document-secrets_full_access"></a> [aws\_iam\_policy\_document-secrets\_full\_access](#output\_aws\_iam\_policy\_document-secrets\_full\_access) | n/a |
| <a name="output_aws_secrets_manager_secret-batch"></a> [aws\_secrets\_manager\_secret-batch](#output\_aws\_secrets\_manager\_secret-batch) | n/a |
| <a name="output_caller_arn"></a> [caller\_arn](#output\_caller\_arn) | n/a |
| <a name="output_caller_user"></a> [caller\_user](#output\_caller\_user) | n/a |
| <a name="output_id"></a> [id](#output\_id) | ID of the created example |
<!-- markdownlint-restore -->
