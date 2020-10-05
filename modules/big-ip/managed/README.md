# BIG-IP instance module

This module encapsulates the creation of a *Stateful Regional Managed Instance Group*
of BIG-IP instances. In this pattern GCP will create 1 or more BIG-IP VMs that
have a stateful configuration based on a common configuration.

> NOTE: this module does not include firewall rules necessary for application
> traffic ingress or GCP health checks. See [Firewall](#firewall) for details.

## Firewall

*Note:* This module is unsupported and not an official F5 product.

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
