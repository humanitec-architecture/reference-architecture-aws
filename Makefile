TF_DIRS = $(patsubst %/main.tf, %, $(shell find . -type d -name .terraform -prune -o -name 'main.tf' -print))
VALIDATE_TF_DIRS = $(addprefix validate-,$(TF_DIRS))

# Generate docs
.PHONY: docs
docs:
	terraform-docs --lockfile=false ./modules/base
	terraform-docs --config docs/.terraform-docs.yaml .
	terraform-docs --config docs/.terraform-docs-example.yaml .
	terraform-docs --config docs/.terraform-docs.yaml ./examples/with-backstage
	terraform-docs --config docs/.terraform-docs-example.yaml ./examples/with-backstage

# Format all terraform files
fmt:
	terraform fmt -recursive

# Check if all terraform files are formatted
fmt-check:
	terraform fmt -recursive -check

# Validate a terraform directories
$(VALIDATE_TF_DIRS): validate-%:
	@echo "Validate $*"
	terraform -chdir="$*" init -upgrade
	terraform -chdir="$*" validate

# Validate all terraform directories
validate: $(VALIDATE_TF_DIRS)
	@echo "All validated"
