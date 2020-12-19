# Test harness runner
#
# HARNESS_PROJECT_ID - the GCP project id to use for testing
# HARNESS_TF_SA_EMAIL - the GCP SA account to use via impersonation; if provided
#                       and IAM roles are set correctly then resource creation,
#                       destruction, and checking will be through this account.

ifneq ("${HARNESS_PROJECT_ID}", "")
	PROJECT_VAR_ARG := -var 'project_id=${HARNESS_PROJECT_ID}'
else
	PROJECT_VAR_ARG :=
endif
ifneq ("${HARNESS_TF_SA_EMAIL}", "")
	TF_SA_EMAIL_VAR_ARG := -var 'tf_sa_email=${HARNESS_TF_SA_EMAIL}'
else
	TF_SA_EMAIL_VAR_ARG :=
endif

.PHONY: test
verify: test/setup/harness.tfvars
	kitchen verify

.PHONY: converge
converge: test/setup/harness.tfvars
	kitchen converge

# setup target makes sure the shared harness VPCs, service accounts, etc. are
# ready for use
.PHONY: setup
setup: test/setup/harness.tfvars

# Two-step apply is hacky but ensures that all relevant state is managed and
# available to Terraform across invocations
test/setup/harness.tfvars: $(wildcard test/setup/*.tf)
	cd test/setup && \
		terraform init -input=false && \
		terraform apply -input=false -auto-approve -target random_pet.prefix $(PROJECT_VAR_ARG) $(TF_SA_EMAIL_VAR_ARG) && \
		terraform apply -input=false -auto-approve $(PROJECT_VAR_ARG) $(TF_SA_EMAIL_VAR_ARG) && \
		terraform output > $(@F)

.PHONY: teardown
teardown:
	kitchen destroy
	cd test/setup && \
		terraform destroy -auto-approve $(PROJECT_VAR_ARG) $(TF_SA_EMAIL_VAR_ARG) && \
		rm -f harness.tfvars
