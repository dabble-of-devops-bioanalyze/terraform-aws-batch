## QuickStart

```{note}
Using the BioAnalyze project templates assumes some familiarity with using a terminal, configuration formats, and Makefiles.
```

Run the cookiecutter command to generate a project template.

Your project name is a concatenation of `["namespace", "environment", "stage", "name", "attributes"]` with `-` between. You can leave any of them out.

For example:

```json
{
    "namespace" : "bioanalyze",
    "environment" : "eks",
    "stage" : "dev"
}
```

Results in the project name: `bioanalyze-eks-dev`.

```{note}
Before deploying your resources I *highly* recommend that you think about how you would like to name your resources. Choose a naming convention that makes sense for you.

Often I see projects the `namespace` based on lab, project, or analysis, `environment` as the AWS Infrastructure type such as Batch, SLURM, or Kubernetes, and stage as the usual `dev`, `stage`, `prod`.

Examples:

| namespace | stage | environment |
| :----------  | :---------- | :---------- |
| lab-a     | dev, stage, prod | fargate-batch, ec2-batch, eks, slurm |
| lab-b     | dev, stage, prod | fargate-batch, ec2-batch, eks, slurm |
| analysis-b     | dev, stage, prod | fargate-batch, ec2-batch, eks, slurm |
| analysis-a     | dev, stage, prod | fargate-batch, ec2-batch, eks, slurm |
```

### Run with the default settings

The simplest way to run cookiecutter is by using the default CLI and running through the prompts.

```
cookiecutter \
	git@github.com:dabble-of-devops-bioanalyze/terraform-aws-batch.git \
	--directory _templates/examples/ec2
```

### Supply variables from a configuration file

Some recipes have a lot of variables, and you may not be ready to decide them all in one go.

If that is the case create a `config.json` file and feed that to cookiecutter. At a minimum you need to include your project name. For more information on naming schemas see. {ref}`terraform-module-naming-convention`

```json
{
    "namespace" : "bioanalyze",
    "environment" : "eks",
    "stage" : "dev"
}
```

#### From the CLI

Run cookiecutter with your supplied config and use the suppress user input options.

```bash
cookiecutter \
	git@github.com:dabble-of-devops-bioanalyze/terraform-aws-batch.git \
	--directory _templates/examples/ec2 \
    --config-file path-to-config.json \
    --no-input
```

#### From a Python Console

Or from a python script or console:

```python
from cookiecutter.main import cookiecutter

cookiecutter(git@github.com:dabble-of-devops-bioanalyze/terraform-aws-batch.git,
        directory=_templates/examples/ec2,
        no_input=True,
        # add your own namespace/environment/stage here
        extra_context= {
            "namespace" : "bioanalyze",
            "environment" : "eks",
            "stage" : "dev"
        })
```

## Customizing your Deployment with Terraform Variables

From here take a look at the `terraform.example.tfvars` and the `terraform.example.tfvars.json` file.

Each of these files serves the same purpose, to add variables to our deployment. Pick one of these files and rename it remove the `.example` from the name.

```bash
cp terraform.example.tfvars terraform.tfvars.json
```

Or:

```bash
cp terraform.example.tfvars terraform.tfvars.json
```

```{warning}
Make sure to use only one file, either the `tfvars` or the `tfvars.json`. Using both will make the computer lose it's mind.
```

```{note}
This quickstart is shared among many modules. For individual tips and tricks please see the documentation for that module.
```

## Deploy your Infrastructure

In any BioAnalyze project the `Makefile` is always the source of truth and light.

```bash
make help
# Initialize the terraform module. This does some sanity checks and downloads any needed external modules.
make terraform/init
# Planning will tell you what resources will be created/destroyed
make terraform/plan
make terraform/apply
# If you're sure you can run the auto-approve
#make terraform/apply/autoapprove
```

## Save, Share and Reproduce your Infrastructure

We use [Terraform](https://www.terraform.io/) to deploy our resources in large part because it saves and backs up the state, which is mostly whether or not we have created our resources. By default running `terraform apply` will save your state to a `terraform.tfstate` file. You should not share this file publically or commit to a public github repo.

It is recommended to save your terraform state to a [remote backend](https://www.terraform.io/docs/language/settings/backends/remote.html). A single remote backend can house multiple deployments.

I recommend using the [Cloudposse Remote S3 Backend](https://github.com/cloudposse/terraform-aws-tfstate-backend).

```bash
mkdir -p terraform-remote-backend
cd terraform-remote-backend
touch main.tf
```

Grab this code and add it to your `main.tf` file.

```terraform
# main.tf
module "terraform_state_backend" {
   source = "cloudposse/tfstate-backend/aws"
   # Cloud Posse recommends pinning every module to a specific version
   # version     = "x.x.x"
   namespace  = "YOUR_NAMESPACE"
   stage      = "YOUR_STAGE"
   name       = "terraform"
   attributes = ["state"]

   terraform_backend_config_file_path = "."
   terraform_backend_config_file_name = "backend.tf"
   force_destroy                      = false
}
```

If you have terraform installed locally you can run:

```bash
terraform init
terraform plan
terraform apply -auto-approve
terraform init -force-copy
```

You can also grab the `Makefile` here and run:

```bash
# Initialize the terraform module. This does some sanity checks and downloads any needed external modules.
make terraform/init
# Planning will tell you what resources will be created/destroyed
make terraform/plan
# If you're sure you can run the auto-approve
make terraform/apply/autoapprove
make terraform/init/force-copy
```

You will now see a `backend.tf` file with your backend configuration. The configuration for the remote backend state is also saved in the `key`: `terraform.tfstate`

```
# backend.tf
 backend "s3" {
   region         = "us-east-1"
   bucket         = "< the name of the S3 state bucket >"
   key            = "terraform.tfstate"
   dynamodb_table = "< the name of the DynamoDB locking table >"
   profile        = ""
   role_arn       = ""
   encrypt        = true
 }
```

In order to use this backend in another project copy the generated `backend.tf` file in your `terraform-remote-backend` directory, but change `key`.

Most often I use the backend `key` to house the `environment` tag.

| namespace | stage | environment |
| :----------  | :---------- | :---------- |
| bioanalyze     | test | ec2-batch |

```terraform
# Example terraform state for:
# namespace=bioanalyze
# stage=test
# environment=ec2-batch

# backend.tf
 terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "bioanalyze-test-terraform-state"
    key            = "ec2-batch"
    dynamodb_table = "bioanalyze-test-terraform-state-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}

```

Here is an example directory structure.

```bash
.
└── bioanalyze
    ├── dev
    │   ├── ec2-batch
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   ├── eks
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   └── fargate-batch
    │       ├── backend.tf
    │       └── main.tf
    ├── prod
    │   ├── ec2-batch
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   ├── eks
    │   │   ├── backend.tf
    │   │   └── main.tf
    │   └── fargate-batch
    │       ├── backend.tf
    │       └── main.tf
```


(terraform-module-naming-convention)=
## Terraform Module Naming Convention

This is a cookicutter template to create Terraform modules based on the [BioAnalyze](https://www.bioanalyze.io) terraform recipe examples.

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

Before you start creating multiple projects it's recommended that you document your naming convention.

## Terraform Resources

[Terraform Variables](https://www.terraform.io/docs/language/values/variables.html)
