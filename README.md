# Unofficial F5 Terraform modules for GCP

This repo contains unofficial and unsupported<sup>1</sup> Terraform modules to
deploy F5 solutions on Google Cloud Platform, using a modular approach that can
be composed into a solution that is consistent for each variant of a product.

> NOTE: The modules **do not** include setup and configuration of supporting
> resources, such as firewall rules or service accounts.

## BIG-IP

The BIG-IP modules build on each other to have a similar API (Terraform input
variables), promoting consistency and reuse.

1. [x] [Standalone](modules/big-ip/instance/) BIG-IP instances
   * [x] Support 1-8 network interfaces
   * [x] Opinionated startup scripts
   * [x] Specify default gateway for
   * [x] [AS3](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/) support
   * [x] [DO](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/) support
2. [x] [HA](modules/big-ip/ha/) BIG-IP instances
   * [ ] [CFE](https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest/) Cloud Failover Extension support
3. [ ] Autoscaling
4. [ ] WAF
5. [ ] GKE integration with [CIS](https://www.f5.com/products/automation-and-orchestration/container-ingress-services)

## NGINX+

TBD

## Cloud Services

TBD

---

<sup>1</sup>This repo will be maintained on a best-effort basis, but is not a
substitute for F5 support.
