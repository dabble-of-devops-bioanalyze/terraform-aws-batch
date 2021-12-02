# Examples

This directory contains the examples for generating AWS Batch clusters.

The examples are meant to give some common scenarios for using the main module. They do not cover every use case. If you think a module should have a particular example please reach out and request an example on [github](https://github.com/dabble-of-devops-bioanalyze/terraform-aws-batch) by creating an issue.

## AWS Batch  - Fargate

The Fargate example deploys [AWS Batch with a Fargate backend](https://docs.aws.amazon.com/batch/latest/userguide/fargate.html).

Fargate can be a great starting point. If you are cost sensitive the `FARGATE_SPOT` option can save you some cash.

According to AWS, these are the circumstances that you should not use Fargate.

* more than 4 vCPUs
* more than 30 gibibytes (GiB) of memory
* a GPU
* Arm-based AWS Graviton CPU
* a custom Amazon Machine Image (AMI)
* any of the linuxParameters parameters such as tmpfs or mounting EFS.

