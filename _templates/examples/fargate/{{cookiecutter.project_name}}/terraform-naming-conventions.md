(terraform-module-naming-convention)=
# Terraform Module Naming Convention

Before you start creating multiple projects it's recommended that you document your naming convention.

We use the [CloudPosse](https://github.com/cloudposse/terraform-example-module) as a base, and the [Label](https://github.com/cloudposse/terraform-null-label) module to generate a name.

The name is generated as:

```
delimiter = '-'

label_order         = ["namespace", "environment", "stage", "name", "attributes"]
id_context = {
    "namespace" : "",
    "tenant" : "",
    "name" : "",
    "environment" : "",
    "stage"       : "",
    "name"       : ""
}

labels = []
for l in label_order:
    if l in id_context and l:
        labels.append(id_context[l])

id_full = delimiter.join(labels)

None
```

You do not need to include all the labels. Usually I only use namespace, environment, and stage.

```
namespace = "bioanalyze"
environment = "eks"
stage = "dev"
```

Would result in the project name `bioanalyze-eks-dev`.

Here is an example directory structure.

```bash
└── bioanalyze
    ├──ec2-batch
    │   ├── dev
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   ├── prod
    │   │   ├── backend.tf
    │   │   └── main.tf
    ├── fargate-batch
    │   ├── dev
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   ├── prod
    │   │   ├── backend.tf
    │   │   └── main.tf
    ├── eks
    │   ├── dev
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   ├── prod
    │   │   ├── backend.tf
    │   │   └── main.tf
```
## Complex Naming Conventions

Now let's say that you have a lab, that does both cellpainting and single cell. You want to have separate Batch environments for each of these, as well as seperate EKS environments for various data visualization applications. In this scenario I would bring in the `name` variable of the backend.

```bash
└── bioanalyze
    ├── ec2-batch
    │   └── dev
    │       ├── cellpainting
    │       │   ├── backend.tf
    │       │   └── main.tf
    │       └── single-cell
    │           ├── backend.tf
    │           └── main.tf
    └── eks
        └── dev
            ├── dash-bio
            │   ├── backend.tf
            │   └── main.tf
            └── rshiny-omics
                ├── backend.tf
                └── main.tf
```

Or in tabular format:

| namespace | stage | environment | name |
| :----------  | :---------- | :---------- | :---------- |
| bioanalyze   | dev | eks | rshiny-omics |
| bioanalyze   | dev | eks | dash-bio |
| bioanalyze   | dev | fargate-batch | cellpainting |
| bioanalyze   | dev | fargate-batch | single-cell |
| bioanalyze   | prod | eks | rshiny-omics |
| bioanalyze   | prod | eks | dash-bio |
| bioanalyze   | prod | fargate-batch | cellpainting |
| bioanalyze   | prod | fargate-batch | single-cell |


```terraform
# bioanalyze/eks/dev/rshiny-omics/backend.tf
backend "s3" {
    region         = "us-east-1"
    bucket         = "bioanalyze-eks-dev"
    key            = "bioanalyze-eks-dev-rshiny-omics"
    dynamodb_table = "bioanalyze-eks-dev"
    profile        = ""
    role_arn       = ""
    encrypt        = true
}
```

## Terraform Naming Convention Benefits

Using a consistent naming convention will save you from lots of headache and frustration. By default all of [BioAnalyze](https://www.bioanalyze.io) modules and [CloudPosse](https://cloudposse.com/) module will tag your AWS Infrastructure resources using your naming convention. This allows you to track the activity and costs of your AWS resources using a combination of [resource groups](https://docs.aws.amazon.com/ARG/latest/userguide/resource-groups.html) and the AWS Billing console.

## Resources

[BioAnalyze](https://www.bioanalyze.io)
[Dabble of DevOps - Consulting](https://www.dabbleofdevops.com)
[Terraform Variables](https://www.terraform.io/docs/language/values/variables.html)
[AWS Resource Groups](https://docs.aws.amazon.com/ARG/latest/userguide/resource-groups.html)
[CloudPosse Naming Module](https://github.com/cloudposse/terraform-null-labe)