.DEFAULT_GOAL := help

TF               ?= terraform
ENV              ?= dev
BOOTSTRAP_TFVARS ?= environments/shared.tfvars
STATE_BUCKET     ?=
STATE_PREFIX     ?= astrafy-bch-analytics/$(ENV)

.PHONY: help fmt fmt-fix validate validate-bootstrap validate-primary \
        bootstrap-init bootstrap-plan bootstrap-apply init plan apply output

help:
	@echo "Usage: make <target> [ENV=dev|prod] [STATE_BUCKET=<bucket>]"
	@echo ""
	@echo "Targets:"
	@echo "  fmt              Check Terraform formatting recursively"
	@echo "  fmt-fix          Format Terraform files recursively"
	@echo "  validate         Initialize without a backend and validate both stacks"
	@echo "  bootstrap-plan   Plan the state project and versioned state bucket"
	@echo "  bootstrap-apply  Apply the reviewed bootstrap plan interactively"
	@echo "  init             Configure the primary GCS backend"
	@echo "  plan             Plan the selected primary environment"
	@echo "  apply            Apply the selected primary environment interactively"
	@echo "  output           Show primary stack outputs"

fmt:
	$(TF) fmt -check -recursive

fmt-fix:
	$(TF) fmt -recursive

validate: validate-bootstrap validate-primary

validate-bootstrap:
	$(TF) -chdir=bootstrap init -backend=false -input=false
	$(TF) -chdir=bootstrap validate

validate-primary:
	$(TF) -chdir=. init -backend=false -input=false
	$(TF) -chdir=. validate

bootstrap-init:
	$(TF) -chdir=bootstrap init -input=false

bootstrap-plan:
	$(TF) -chdir=bootstrap plan -input=false -lock-timeout=5m -var-file="$(BOOTSTRAP_TFVARS)"

bootstrap-apply:
	$(TF) -chdir=bootstrap apply -var-file="$(BOOTSTRAP_TFVARS)"

init:
	$(TF) -chdir=. init -input=false -backend-config="bucket=$(STATE_BUCKET)" -backend-config="prefix=$(STATE_PREFIX)"

plan:
	$(TF) -chdir=. plan -input=false -lock-timeout=5m -var-file="environments/$(ENV).tfvars"

apply:
	$(TF) -chdir=. apply -var-file="environments/$(ENV).tfvars"

output:
	$(TF) -chdir=. output
