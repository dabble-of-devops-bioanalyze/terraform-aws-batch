mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
DOCKER_IMAGE := dabbleofdevops/terraform:terraform-0.14.0

# Put it first so that "make" without argument is like "make help".

.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## terraform/shell: drop into a shell
terraform/shell:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash

## terraform/init: initialize terraform
terraform/init:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform init"

## terraform/init/force-copy: initialize terraform and run force-copy to copy the backend.
terraform/init/force-copy:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform init -force-copy"

## terraform/refresh: refresh terraform state
terraform/refresh:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform refresh"

## terraform/plan: plan terraform configuration
terraform/plan:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform plan"

## terraform/apply: apply terraform configuration
terraform/apply:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform apply"

## terraform/apply/autoapprove: apply terraform configuration
terraform/apply/autoapprove:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform apply -auto-approve"
