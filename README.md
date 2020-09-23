# Unofficial F5 Terraform modules for GCP

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

## Rationale

The intent is allow for integration of BIG-IP, NGINX+, and other F5 products
with GCP infrastructure that is managed using Google's
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

## BIG-IP

The [BIG-IP](modules/big-ip) modules build on each other to have a similar AP
(implemented as Terraform input variables), promoting consistency and reuse. For
more information about these open the README files in each module.

1. [x] [Standalone](modules/big-ip/instance/) BIG-IP instances
   * [x] Support 1-8 network interfaces
   * [x] Opinionated startup scripts
   * [x] Override default gateway when needed; e.g. for bootstrapping in a restricted
         VPC where data-plane does not have egress.
   * [x] [AS3](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/) support
   * [x] [DO](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/) support
2. [x] [HA](modules/big-ip/ha/) BIG-IP clustered instances
   * [x] [CFE](modules/big-ip/cfe/) [Cloud Failover Extension](https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest/) support
3. [ ] Autoscaling
4. [ ] WAF
5. [ ] GKE integration with [CIS](https://www.f5.com/products/automation-and-orchestration/container-ingress-services)

## NGINX+

TBD

## Cloud Services

TBD

---

<!-- markdownlint-disable MD033 -->
<sup>1</sup>This repo will be maintained on a best-effort basis, but is not a
substitute for F5 support.
<!-- markdownlint-enable MD033 -->
