
fargate/shell:
	docker run --rm -it \
		-v $(shell pwd)/../.aws:/root/.aws \
		-v $(shell pwd)/../:/root/project \
		-w /root/project/examples/fargate \
		dabbleofdevops/terraform:terraform-0.14.0 bash

ec2/shell:
	docker run --rm -it \
		-v $(shell pwd)/../.aws:/root/.aws \
		-v $(shell pwd):/root/project \
		-w /root/project/ec2 \
		-v /Users/jillian/Dropbox/projects/personal/DODO/consulting/DODO/biohub/terraform-recipes:/root/terraform-recipes \
		dabbleofdevops/terraform:terraform-0.14.0 bash
