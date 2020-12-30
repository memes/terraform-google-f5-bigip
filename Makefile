# Test harness runner
#

# Converge all suites, wait 10 mins then try to verify. If this fails use the verify
# target to repeat.
.PHONY: all
all: test/setup/harness.tfvars
	kitchen converge
	echo "Sleeping for 10 mins"
	sleep 600
	kitchen list --bare | xargs -n 1 kitchen verify

# kitchen, kitchen-terraform, and shared profiles do not use the correct inputs
# if a bare `kitchen verify` is executed (first suite Terraform output becomes
# input for all other suites). To work around this, invoke each suite independently
# to ensure the inputs are set from the correct Terraform workspace.
.PHONY: verify
verify: test/setup/harness.tfvars
	kitchen list --bare | xargs -n 1 kitchen verify

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
		terraform apply -input=false -auto-approve -target random_pet.prefix && \
		terraform apply -input=false -auto-approve && \
		terraform output > $(@F)

.PHONY: teardown
teardown:
	kitchen destroy
	cd test/setup && \
		terraform destroy -auto-approve && \
		rm -f harness.tfvars
