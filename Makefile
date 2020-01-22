SHELL:=bash

aws_profile=dataworks-development
aws_region=eu-west-2

default: help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Bootstrap local environment for first use
	make dependencies
	make git-hooks
	make bootstrap-terraform

.PHONY: dependencies
dependencies: ## Install Python dependencies
	pip3 install --user Jinja2 PyYAML boto3

PHONY: git-hooks
git-hooks: ## Set up hooks in .git/hooks
	@{ \
		HOOK_DIR=.git/hooks; \
		for hook in $(shell ls .githooks); do \
			if [ ! -h $${HOOK_DIR}/$${hook} -a -x $${HOOK_DIR}/$${hook} ]; then \
				mv $${HOOK_DIR}/$${hook} $${HOOK_DIR}/$${hook}.local; \
				echo "moved existing $${hook} to $${hook}.local"; \
			fi; \
			ln -s -f ../../.githooks/$${hook} $${HOOK_DIR}/$${hook}; \
		done \
	}

.PHONY: bootstrap-terraform
bootstrap-terraform: ## Bootstrap local environment for first use
	@{ \
		export AWS_PROFILE=$(aws_profile); \
		export AWS_REGION=$(aws_region); \
		python3 bootstrap_terraform.py; \
	}

.PHONY: bootstrap-terraform-dev
bootstrap-terraform-dev: ## Bootstrap local environment for first use
	make bootstrap-terraform
	/usr/bin/sed -i '' 's|"default" ? "management-dev"|"default" ? "development"|g' terraform/deploy/terraform.tf
	/usr/bin/sed -i '' 's|terraform/dataworks/aws-concourse.tfstate|terraform/dataworks/aws-concourse-${shell git rev-parse --abbrev-ref HEAD}.tfstate|g' terraform/deploy/terraform.tf
