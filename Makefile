# Test harness runner

SCENARIOS := $(subst /,,$(subst test/integration/,,$(dir $(wildcard test/integration/*/.))))

# Converge all suites, verify, and destroy; first failure will terminate the suite
# NOTE: this will converge ALL scenarios before verification, which could cause
# quota issues. See `serialised` target to execute each suite in turn without
# spinning up too many instances at once.
.PHONY: all
all: converge $(addprefix verify.,$(SCENARIOS))
	kitchen destroy

.PHONY: converge
converge: test/setup/harness.tfvars
	kitchen converge

# 'Quick' version of the all target that skips the controls that need BIG-IP to
# settle. Not a full test but confirms GCE properties, etc. Useful during module
# development and refactoring.
.PHONY: quick
quick: converge $(addprefix qverify.,$(SCENARIOS))
	kitchen destroy

# Execute `kitchen test` against each scenario (as represented by a directory in
# test/integration) individually. E.g. converge/verify/destroy scenario #1,
# converge/verify/destroy scenario #2, etc.
# NOTE: This approach will be slower than the default `all` target as
# onboarding_delay will be observed for each scenario individually.
.PHONY: serialised
serialised: $(addprefix test.,$(SCENARIOS))

# Targets below here provide a way to run a kitchen test/destroy/verify run for
# an individual scenario knowing that the foundational harness will be created
# as needed. Just prefix scenario with the kitchen `command.`. Use q-variants
# to skip tests that require full-onboarding to complete.
# E.g. make test.root-1nic-minimal
#      make qtest.cfe-8nic-full

.PHONY: qtest.%
qtest.%:  test/setup/harness.tfvars
	KITCHEN_SKIP_ONBOARD_DELAY=1 kitchen test $*

.PHONY: test.%
test.%: test/setup/harness.tfvars
	kitchen test $*

.PHONY: destroy.%
destroy.%: test/setup/harness.tfvars
	kitchen destroy $*

.PHONY: qverify.%
qverify.%: test/setup/harness.tfvars
	KITCHEN_SKIP_ONBOARD_DELAY=1 kitchen verify $*

.PHONY: verify.%
verify.%: test/setup/harness.tfvars
	kitchen verify $*

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
teardown:
	kitchen destroy
	cd test/setup && \
		terraform destroy -auto-approve && \
		rm -f harness.tfvars
