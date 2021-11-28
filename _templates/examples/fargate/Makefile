mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
DOCKER_IMAGE := dabbleofdevops/terraform:terraform-0.14.0

# Put it first so that "make" without argument is like "make help".

.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## terraform/init: initialize terraform
terraform/init:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform init"


## terraform/refresh: refresh terraform state
terraform/refresh:
	docker run --rm -it \
		-v $(shell pwd):/tmp/terraform-module \
		-w /tmp/terraform-module \
		$(DOCKER_IMAGE) bash -c "terraform refresh"


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
