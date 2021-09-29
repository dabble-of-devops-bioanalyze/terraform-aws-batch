
<!-- markdownlint-disable -->
# terraform-aws-batch [![Latest Release](https://img.shields.io/github/release/Dabble-of-Devops-BioHub/terraform-aws-batch.svg)](https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch-module/releases/latest)
<!-- markdownlint-restore -->

![BioAnalyze Logo](https://raw.githubusercontent.com/Dabble-of-DevOps-BioAnalyze/biohub-info/master/logos/BioAnalyze_v2-01.jpg)

<!--




  ** DO NOT EDIT THIS FILE
  **
  ** This file was automatically generated by the `build-harness`.
  ** 1) Make all changes to `README.yaml`
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file.
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **





-->

The `terraform-aws-batch` recipe provides a starter template for getting started with AWS Batch. It creates:

  * AWS Batch Compute Environment
    ** Configured for use with the AWS Secrets Manager
  * AWS Job Queue associated to the created Compute Environment

---

This project is part of the ["BioAnalyze"](https://www.dabbleofdevops.com/biohub) project, which aims to make High Performance Compute Architecture accessible to everyone.


It's 100% Open Source and licensed under the [APACHE2](LICENSE).






## Data Science Infrastructure on AWS

![BioAnalyze Logo](https://raw.githubusercontent.com/dabble-of-devops-bioanalyze/biohub-info/master/images/BioAnalyze-Ecosystem-Data-Visualization.jpeg)






**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

Also, because of a bug in the Terraform registry ([hashicorp/terraform#21417](https://github.com/hashicorp/terraform/issues/21417)),
the registry shows many of our inputs as required when in fact they are optional.
The table below correctly indicates which inputs are required.


For a complete example, see [examples/complete](examples/complete).

For automated tests of the complete example using [bats](https://github.com/bats-core/bats-core) and [Terratest](https://github.com/gruntwork-io/terratest)
(which tests and deploys the example on AWS), see [test](test).

```hcl
module "example" {
  source = "https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch.git?ref=master"
}
```

More complete documentation and tutorials coming soon!


## Examples

Here is an example of using this module:
- [`examples/complete`](https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch/) - complete example of using this module



<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
<!-- markdownlint-restore -->
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
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_batch_compute_environment.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) | resource |
| [aws_batch_job_queue.default_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_iam_instance_profile.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.aws_batch_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.batch_secrets_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_batch_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.aws_batch_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_secretsmanager_secret.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_security_group.batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ecs_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [template_file.launch_template_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_additional_user_data"></a> [additional\_user\_data](#input\_additional\_user\_data) | Additional User Data for the launch template.  Must include ==MYBOUNDARY== and Content-Type: entries. | `string` | `""` | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | List of owners for source ECS AMI. | `list` | <pre>[<br>  "amazon"<br>]</pre> | no |
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
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Optional list of instance types. | `list` | <pre>[<br>  "optimal"<br>]</pre> | no |
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
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of additional security groups to associate with cluster instances.  If empty, default security group will be added. | `list` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets compute environment instances will be deployed in. | `list` | n/a | yes |
| <a name="input_tag_specifications_resource_types"></a> [tag\_specifications\_resource\_types](#input\_tag\_specifications\_resource\_types) | List of tag specification resource types to tag. Valid values are instance, volume, elastic-gpu and spot-instances-request. | `set(string)` | <pre>[<br>  "instance",<br>  "volume"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_aws_batch_compute_environment"></a> [aws\_batch\_compute\_environment](#output\_aws\_batch\_compute\_environment) | n/a |
| <a name="output_aws_batch_ecs_instance_role"></a> [aws\_batch\_ecs\_instance\_role](#output\_aws\_batch\_ecs\_instance\_role) | n/a |
| <a name="output_aws_batch_job_queue"></a> [aws\_batch\_job\_queue](#output\_aws\_batch\_job\_queue) | n/a |
| <a name="output_aws_batch_secrets_role"></a> [aws\_batch\_secrets\_role](#output\_aws\_batch\_secrets\_role) | n/a |
| <a name="output_aws_batch_service_role"></a> [aws\_batch\_service\_role](#output\_aws\_batch\_service\_role) | n/a |
| <a name="output_aws_iam_role-batch_secrets_role"></a> [aws\_iam\_role-batch\_secrets\_role](#output\_aws\_iam\_role-batch\_secrets\_role) | n/a |
| <a name="output_aws_secrets_manager_secret-batch"></a> [aws\_secrets\_manager\_secret-batch](#output\_aws\_secrets\_manager\_secret-batch) | n/a |
| <a name="output_caller_arn"></a> [caller\_arn](#output\_caller\_arn) | n/a |
| <a name="output_caller_user"></a> [caller\_user](#output\_caller\_user) | n/a |
| <a name="output_id"></a> [id](#output\_id) | ID of the created example |
<!-- markdownlint-restore -->




## Share the Love

Like this project? Please give it a ★ on [our GitHub](https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch)! (it helps **a lot**)



## Related Projects

Check out these related projects.

- [terraform-aws-eks-autoscaling](https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-eks-autoscaling) - Wrapper module for terraform-aws-eks-cluster, terraform-aws-eks-worker, and terraform-aws-eks-node-group
- [terraform-aws-eks-cluster](https://github.com/cloudposse/terraform-aws-eks-cluster/) - Base CloudPosse module for AWS EKS Clusters"
- [terraform-null-label](https://github.com/cloudposse/terraform-null-label) - Terraform module designed to generate consistent names and tags for resources. Use terraform-null-label to implement a strict naming convention.


## References

For additional context, refer to some of these links.

- [Terraform Standard Module Structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure) - HashiCorp's standard module structure is a file and directory layout we recommend for reusable modules distributed in separate repositories.
- [Terraform Module Requirements](https://www.terraform.io/docs/registry/modules/publish.html#requirements) - HashiCorp's guidance on all the requirements for publishing a module. Meeting the requirements for publishing a module is extremely easy.
- [Terraform `batch_compute_environment` Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) - Creates a AWS Batch compute environment. Compute environments contain the Amazon ECS container instances that are used to run containerized batch jobs.
- [Terraform `batch_job_queue` Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) - Provides a Batch Job Queue resource.
- [Terraform `batch_job_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_definition) - Provides a Batch Job Definition resource.
- [Terraform `random_integer` Resource](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) - The resource random_integer generates random values from a given range, described by the min and max attributes of a given resource.
- [Terraform Version Pinning](https://www.terraform.io/docs/configuration/terraform.html#specifying-a-required-terraform-version) - The required_version setting can be used to constrain which versions of the Terraform CLI can be used with your configuration


## Help

**Got a question?** We got answers.

File a GitHub [issue](https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch/issues), send us an jillian@dabbleofdevops.com.

## Bioinformatics Infrastructure on AWS for Startups

I'll help you build your data science cloud infrastructure from the ground up so you can own it using open source software. Then I'll show you how to operate it and stick around for as long as you need us.

[Learn More](https://www.dabbleofdevops.com)

Work directly with me via email, slack, and video conferencing.

- **Scientific Workflow Automation and Optimization.** Got workflows that are giving you trouble? Let's work together to ensure that your analyses run with or without your scientists being fully caffeinated.
- **High Performance Compute Infrastructure.** Highly available, auto scaling clusters to analyze *all the (bioinformatics related!) things*. All setups are completely integrated with your workflow system of choice, whether that is Airflow, Prefect, Snakemake or Nextflow.
- **Kubernetes and AWS Batch Setup for Apache Airflow** Orchestrate your Bioinformatics Workflows with Apache Airflow. Get full auditing, SLA, logging and monitoring for your workflows running on AWS Batch.
- **High Performance Compute Setup that Int** You'll have built-in governance with accountability and audit logs for all changes.
- **Docker Images** Get advice and hands on training for your team to build complex software stacks onto docker images.
- **Training.** You'll receive hands-on training so your team can operate what we build.
- **Questions.** You'll have a direct line of communication between our teams via a Shared Slack channel.
- **Troubleshooting.** You'll get help to triage when things aren't working.
- **Bug Fixes.** We'll rapidly work with you to fix any bugs in our projects.

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or help out with other projects, I would love to hear from you! Shoot me an email at jillian@dabbleofdevops.com.

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!



## Copyrights

Copyright © 2021-2021 [Dabble of DevOps, SCorp](https://www.dabbleofdevops.com)





## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```









## Trademarks

All other trademarks referenced herein are the property of their respective owners.



### Contributors

<!-- markdownlint-disable -->
|  [![Jillian Rowe][jerowe_avatar]][jerowe_homepage]<br/>[Jillian Rowe][jerowe_homepage] |
|---|
<!-- markdownlint-restore -->

  [jerowe_homepage]: https://github.com/jerowe
  [jerowe_avatar]: https://img.cloudposse.com/150x150/https://github.com/jerowe.png

Learn more at [Dabble of DevOps](https://www.dabbleofdevops.com)

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=docs
  [website]: https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=website
  [github]: https://cpco.io/github?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=github
  [jobs]: https://cpco.io/jobs?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=jobs
  [hire]: https://cpco.io/hire?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=hire
  [slack]: https://cpco.io/slack?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=slack
  [linkedin]: https://cpco.io/linkedin?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=linkedin
  [twitter]: https://cpco.io/twitter?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=twitter
  [testimonial]: https://cpco.io/leave-testimonial?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=testimonial
  [office_hours]: https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=office_hours
  [newsletter]: https://cpco.io/newsletter?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=newsletter
  [discourse]: https://ask.sweetops.com/?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=discourse
  [email]: https://cpco.io/email?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=email
  [commercial_support]: https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=commercial_support
  [we_love_open_source]: https://cpco.io/we-love-open-source?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=we_love_open_source
  [terraform_modules]: https://cpco.io/terraform-modules?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=terraform_modules
  [readme_header_img]: https://cloudposse.com/readme/header/img
  [readme_header_link]: https://cloudposse.com/readme/header/link?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=readme_header_link
  [readme_footer_img]: https://cloudposse.com/readme/footer/img
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=readme_footer_link
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?utm_source=github&utm_medium=readme&utm_campaign=Dabble-of-DevOps-BioHub/terraform-aws-batch&utm_content=readme_commercial_support_link
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-batch&url=https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-batch&url=https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch
  [share_email]: mailto:?subject=terraform-aws-batch&body=https://github.com/Dabble-of-DevOps-BioHub/terraform-aws-batch
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/Dabble-of-DevOps-BioHub/terraform-aws-batch?pixel&cs=github&cm=readme&an=terraform-aws-batch
