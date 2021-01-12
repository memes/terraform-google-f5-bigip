# Test harness runner
#
TEST_SLEEP := 600
SCENARIOS := $(subst test/integration/,,$(dir $(wildcard test/integration/*/.)))
PHONY_TESTS := $(addprefix test.,$(SCENARIOS))
PHONY_DESTROYS := $(addprefix destroy.,$(SCENARIOS))

# Converge all suites, verify, and destroy; first failure will terminate the suite
.PHONY: all
all: $(PHONY_TESTS)

# Converge a test scenario, wait 600 secs for it to settle, then verify.
# E.g. make test.root-1nic-minimal
.PHONY: test.%
test.%:  test/setup/harness.tfvars
	kitchen converge $*
	echo "Sleeping for $(TEST_SLEEP) seconds"
	sleep $(TEST_SLEEP)
	kitchen verify $*
	kitchen destroy $*

.PHONY: destroy.%
destroy.%:
	kitchen destroy $*

# Use this target to manually verify a test scenario. E.g. make verify.root-1nic-minimal
.PHONY: verify.%
verify.%: converge.%
	kitchen verify $*

# Use this targets to manually prepare a test scenario without verifying it.
# E.g. make converge.root-1nic-minimal
.PHONY: converge.%
converge.%: test/setup/harness.tfvars
	kitchen converge $*

# Two-step apply is hacky but ensures that all relevant state is managed and
# available to Terraform across invocations
test/setup/harness.tfvars: $(wildcard test/setup/*.tf)
	cd test/setup && \
		terraform init -input=false && \
		terraform apply -input=false -auto-approve -target random_pet.prefix && \
		terraform apply -input=false -auto-approve && \
		terraform output > $(@F)

.PHONY: teardown
teardown: $(PHONY_DESTROYS)
	cd test/setup && \
		terraform destroy -auto-approve && \
		rm -f harness.tfvars
