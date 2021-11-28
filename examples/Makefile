
fargate-batch-shell:
	docker run --rm -it \
		-v $(shell pwd)/../.aws:/root/.aws \
		-v $(shell pwd):/root/project \
		-v /Users/jillian/Dropbox/projects/personal/DODO/consulting/DODO/biohub/terraform-recipes:/root/terraform-recipes \
		dabbleofdevops/terraform:terraform-0.14.0 bash