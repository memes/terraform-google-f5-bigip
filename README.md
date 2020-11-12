# Unofficial F5 BIG-IP Terraform modules for Google Cloud Platform

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 -->
This repo contains unofficial and unsupported<sup>1</sup> Terraform modules to
deploy F5 solutions on Google Cloud Platform, using a modular approach that can
be composed into a solution that is consistent for each variant of a product.
<!-- markdownlint-enable MD033 -->

> NOTE: The modules **do not** include setup and configuration of supporting
> resources, such as ingress firewall rules or service accounts. Where required,
> the examples will include the bare-minimum setup to show demonstrate usage.
> Some modules will include links to other public GitHub repositories that
> demonstrate specific use-cases.

<!-- spell-checker:ignore NICs, secretmanager -->
These modules support deploying supported BIG-IP versions instances to Google
Cloud in an opinionated manner. By themselves they do not implement a full stack
or solution, and additional setup will be needed for firewall rules, service
account creation and role assignments.

## Options

These BIG-IP modules build on each other to have a similar API
(implemented as Terraform input variables), promoting consistency and reuse. For
more information about these open the README files in each module.

1. [x] Standalone BIG-IP instances
   * [x] Support 1-8 network interfaces
   * [x] Opinionated startup scripts
   * [x] Override default gateway when needed; e.g. for bootstrapping in a restricted
         VPC where data-plane does not have egress.
   * [x] [AS3](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/) support
   * [x] [DO](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/) support
2. [x] [HA](modules/ha/) BIG-IP clustered instances
   * [x] [CFE](modules/cfe/) [Cloud Failover Extension](https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest/) support
3. [ ] Autoscaling and managed groups

## Dependencies

The BIG-IP modules all have a common set of requirements.

1. Terraform 0.12

   A future version of these modules will target Terraform 0.13 once the majority
   of module consumers request it. You can do this by adding a reaction to
   tracking issue #4.

2. Google Cloud [Secret Manager](https://cloud.google.com/secret-manager)

   There are many good options for run-time secret injection but this module is
   supporting Google's Secret Manager only at this time.

3. APIs to enable

   * Compute Engine `compute.googleapis.com`
   * Secret Manager `secretmanager.googleapis.com`
   * Storage (required for CFE) `storage-api.googleapis.com`

## Run-time setup

The BIG-IP modules in this repo support [cloud-init](https://cloudinit.readthedocs.io/en/latest/)
and [metadata-startup-script](https://cloud.google.com/compute/docs/startupscript)
boot options, defaulting to the metadata startup-script for compatibility with
BIG-IP versions 13.x, 14.x, and 15.x. Set the `use_cloud_init` input variable to
`true` to force the use of cloud-init on BIG-IP v15+.

Fundamentally both approaches launch the same shell scripts; the difference is
that `cloud-init` script installs a systemd service unit with dependencies to
prevent early execution, and automatically disables the service unit after
success. The simple metadata startup-script will execute on every boot.

For more information on how run-time configuration is applied to each BIG-IP
instance, see the [configuration details](modules/metadata#configuration) section in [metadata module](modules/metadata).

## Rationale

The intent is allow for integration of BIG-IP with GCP infrastructure that is
managed using Google's
[Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit)
Terraform modules or an equivalent. These are not fully-baked solutions, but can
be integrated to build a reusable deployment pipeline.

For example, the modules do not include ingress firewall rule resources as core
module components. This is because some organizations may mandate use of service
account based rules, where others prefer tag based, or a combination of both where
interfaces are attached to peered VPCs. The exception to this is the firewall
module to support ConfigSync for HA and CFE clusters; since the BIG-IPs will be
deployed to the same VPC networks, it is reasonably safe to assume a service
account based rule will be universally applicable.


---

<!-- markdownlint-disable MD033 -->
<sup>1</sup>This repo will be maintained on a best-effort basis, but is not a
substitute for F5 support.
<!-- markdownlint-enable MD033 -->
