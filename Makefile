# Test harness runner
#
# This Makefile is a helper to standup testing foundations and execute fixtures.
# Most targets will
#  1. Ensure the Terraform in test/setup is executed, generating harness.tfvars
#     and inspec-verifier.json files.
#  2. Emulate common kitchen actions, but with serialised verify steps to avoid
#     reusing the same parameters for multiple test scenarios and with the
#     inspec-verifier service account credentials.

# Tell kitchen to put verify reports here
REPORT_DIR := test/reports/$(shell date '+%Y%m%d')

# Converge all suites, verify, and destroy; first failure will terminate the suite
# NOTE: this will converge ALL scenarios before verification, which could cause
# quota issues. See `serialised` target to execute each suite in turn without
# spinning up too many instances at once.
.PHONY: all
all: test

# 'Quick' version of the all target that skips the controls that need BIG-IP to
# settle. Not a full test but confirms GCE properties, etc. Useful during module
# development and refactoring.
.PHONY: quick
quick: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen converge
	kitchen list --bare | \
		xargs -n 1 -I % sh -c 'REPORT_DIR="$(REPORT_DIR)" KITCHEN_SKIP_ONBOARD_DELAY=1 GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'
	kitchen destroy

# Execute `kitchen test` equivalent against each scenario individually.
# E.g. converge/verify/destroy scenario #1, converge/verify/destroy scenario #2, etc.
# NOTE: This approach will be slower than the default `all` target as
# onboarding_delay will be observed for each scenario individually.
.PHONY: serialised
serialised: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen list --bare | \
		xargs -n 1 -I % sh -c 'kitchen destroy % && kitchen converge % && (REPORT_DIR="$(REPORT_DIR)" GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255) && kitchen destroy %'

# Targets below here provide a way to run a kitchen test/destroy/verify run for
# an individual scenario knowing that the foundational harness will be created
# as needed. Just prefix scenario with the kitchen `command.`. Use q-variants
# to skip tests that require full-onboarding to complete.
# E.g. make test.root-1nic-minimal
#      make qtest.cfe-8nic-full

.PHONY: qtest.%
qtest.%:  test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen destroy $*
	kitchen converge $*
	kitchen list --bare $* | \
		xargs -n 1 -I % sh -c 'REPORT_DIR="$(REPORT_DIR)" KITCHEN_SKIP_ONBOARD_DELAY=1 GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'
	kitchen destroy $*

.PHONY: test.%
test.%: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen destroy $*
	kitchen converge $*
	kitchen list --bare $* | \
		xargs -n 1 -I % sh -c 'REPORT_DIR="$(REPORT_DIR)" GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'
	kitchen destroy $*

.PHONY: test
test: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen destroy
	kitchen converge
	kitchen list --bare | \
		xargs -n 1 -I % sh -c 'REPORT_DIR="$(REPORT_DIR)" GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'
	kitchen destroy

.PHONY: destroy.%
destroy.%: test/setup/harness.tfvars
	kitchen destroy $*

.PHONY: destroy
destroy: test/setup/harness.tfvars
	kitchen destroy

.PHONY: qverify.%
qverify.%: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen converge $*
	kitchen list --bare $* | \
		xargs -n 1 e-I % sh -c 'REPORT_DIR="$(REPORT_DIR)" KITCHEN_SKIP_ONBOARD_DELAY=1 GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'

.PHONY: verify.%
verify.%: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen converge $*
	kitchen list --bare $* | \
		xargs -n 1 -I % sh -c 'REPORT_DIR="$(REPORT_DIR)" GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'

.PHONY: verify
verify: test/setup/harness.tfvars
	mkdir -p "$(REPORT_DIR)"
	kitchen converge
	kitchen list --bare | \
		xargs -n 1 e-I % sh -c 'REPORT_DIR="$(REPORT_DIR)" GOOGLE_APPLICATION_CREDENTIALS=test/setup/inspec-verifier.json kitchen verify % || exit 255'

.PHONY: converge.% converge
converge.%: test/setup/harness.tfvars
	kitchen converge $*

.PHONY: converge
converge: test/setup/harness.tfvars
	kitchen converge

# Two-step apply is hacky but ensures that all relevant state is managed and
# available to Terraform across invocations
test/setup/harness.tfvars: $(wildcard test/setup/*.tf) $(wildcard test/setup/*.auto.tfvars) $(wildcard test/setup/terraform.tfvars)
	cd test/setup && \
		terraform init -input=false && \
		terraform apply -input=false -auto-approve -target random_id.prefix && \
		terraform apply -input=false -auto-approve

.PHONY: teardown
teardown:
	kitchen destroy
	rm -f test/setup/harness.tfvars
	cd test/setup && \
		terraform destroy -auto-approve
