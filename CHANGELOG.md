# Changelog

<!-- spell-checker: ignore markdownlint nics -->
<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## TODO @memes [2.1.0] and [1.4.0] - TBD

This release contains fundamental changes to the way that data-plane interfaces
are initialised. See [CONFIGURATION](CONFIGURATION.md) for more details.

### Added

- Support VIP (Alias IP) CIDRs from secondary ranges (issue [#105](https://github.com/memes/terraform-google-f5-bigip/issues/105))
- Terraform 0.14 is supported (issue [#55](https://github.com/memes/terraform-google-f5-bigip/issues/55))
- Output that lists BIG-IP self-links by compute zone (issue [#52](https://github.com/memes/terraform-google-f5-bigip/issues/52))
- Retry logic when getting a secret from Google Secret Manager (issue [#60](https://github.com/memes/terraform-google-f5-bigip/issues/60))
- Assign reserved public IP addresses to interfaces (issue [[#57](https://github.com/memes/terraform-google-f5-bigip/issues/57)])
- Early setup script which enables and assigns extra RAM to restjavad - resolves intermittent issues when applying DO
  (issues [#73](https://github.com/memes/terraform-google-f5-bigip/issues/73), [#85](https://github.com/memes/terraform-google-f5-bigip/issues/85), [#97](https://github.com/memes/terraform-google-f5-bigip/issues/97))

### Changed

- Updated Cloud libs to latest as of publishing (issue [#94](https://github.com/memes/terraform-google-f5-bigip/issues/94))
- Non-management interface configuration is entirely configured through
  Declarative Onboarding JSON (issue [#23](https://github.com/memes/terraform-google-f5-bigip/issues/23)
  and [#26](https://github.com/memes/terraform-google-f5-bigip/issues/26))
- CFE custom role will automatically generate semi-random identifiers for the role (issue [#61](https://github.com/memes/terraform-google-f5-bigip/issues/61))
- Fixed support for multiple Alias IP definitions applied to multiple internal nics

### Removed

- Do not assign Self-IPs to VIPs in generated DO (issue [#100](https://github.com/memes/terraform-google-f5-bigip/issues/100))
- Terraform lifecycle `create_before_destroy` rule on BIG-IP VM instances (issue [#46](https://github.com/memes/terraform-google-f5-bigip/issues/46))
- Obsolete and unused variables; `description`, `license_type`, `allow_usage_analytics`,
  `region` and `enable_os_login` (issue [#27](https://github.com/memes/terraform-google-f5-bigip/issues/27))
- Unneeded Cloud Libs `f5-cloud-libs.tar.gz` and `f5-cloud-libs-gce.tar.gz`

## [2.0.2] and [1.3.2] - 2020-11-30

### Added

- Support custom domain names (issue [#29](https://github.com/memes/terraform-google-f5-bigip/issues/29))
- Support changing the base number and format specifier used when generating instance names (issue [#24](https://github.com/memes/terraform-google-f5-bigip/issues/24))
- Support setting admin password via cleartext metadata (issue [#21](https://github.com/memes/terraform-google-f5-bigip/issues/21))
- Telemetry Streaming extension installed by default (issue [#22](https://github.com/memes/terraform-google-f5-bigip/issues/22))

### Changed

- Fixed bug installing RPM extensions on BIG-IP v15.1.1 and BIG-IP v15.1.2 (issue [#18](https://github.com/memes/terraform-google-f5-bigip/issues/18))
- Fixed bug when declaring complex 'allow-service' requirements (issue [#25](https://github.com/memes/terraform-google-f5-bigip/issues/25))
- Bumped Cloud Libraries, AS3, DO, and CFE extensions to latest (issue [#22](https://github.com/memes/terraform-google-f5-bigip/issues/22))

### Removed

## [2.0.1] and [1.3.1] - 2020-11-18

### Added

### Changed

- Added Terraform 0.12/0.13 notice to main README

### Removed

## [2.0.0] and [1.3.0] - 2020-11-18

> First of the parallel Terraform 0.13 and Terraform 0.12 specific releases.

### Added

### Changed

- Enforcing Terraform 0.12.x or 0.13.x for 1.x and 2.x releases, respectively
- Bumped Google provider to 3.48.0
- Bumped Google IAM module to 6.4.0

### Removed

## [1.2.2] - 2020-11-18

### Added

### Changed

- Fixed references to modules in examples

### Removed

## [1.2.1] - 2020-11-18

### Added

### Changed

<!-- spell-checker: ignore READMEs -->
- Updated and improved READMEs for modules and examples
- Refactored sub-modules to be at same level below main module to better match
  Terraform registry expectations

### Removed

## [1.2.0] - 2020-11-12

### Added

- HA and CFE examples are using the respective firewall module

### Changed

- *REFACTOR OF MODULES FOR TERRAFORM REGISTRY*
- Updated dependent Terraform providers and modules to latest versions
- Updated pre-commit plugins to latest versions

### Removed

- Future plans for this repo to include NGINX or other F5 products

## [1.1.1] - 2020-09-24

### Added

### Changed

- Bug fixes and documentation updates

### Removed

## [1.1.0] - 2020-09-22

### Added

- CFE module and supporting role

### Changed

- Improved documentation

### Removed

## [1.0.2] - 2020-08-25

### Added

- Onboarding progress is echoed to VM serial console to aid in debugging

### Changed

- Cloud Libs bumped to latest versions

### Removed

## [1.0.1] - 2020-08-20

### Added

- Support for HA clusters

## [1.0.0] - 2020-06-02

### Added

- First published version of BIG-IP module for standalone instances
  - Monorepo with intent to support multiple F5 products

### Changed

### Removed

[2.1.0]: https://github.com/memes/f5-google-terraform-modules/compare/v2.0.2...v2.1.0
[1.4.0]: https://github.com/memes/f5-google-terraform-modules/compare/v1.3.2...v1.4.0
[2.0.2]: https://github.com/memes/f5-google-terraform-modules/compare/v2.0.1...v2.0.2
[1.3.2]: https://github.com/memes/f5-google-terraform-modules/compare/v1.3.1...v1.3.2
[2.0.1]: https://github.com/memes/f5-google-terraform-modules/compare/v2.0.0...v2.0.1
[1.3.1]: https://github.com/memes/f5-google-terraform-modules/compare/v1.3.0...v1.3.1
[2.0.0]: https://github.com/memes/f5-google-terraform-modules/compare/v1.2.2...v2.0.0
[1.3.0]: https://github.com/memes/f5-google-terraform-modules/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/memes/f5-google-terraform-modules/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/memes/f5-google-terraform-modules/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/memes/f5-google-terraform-modules/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/memes/f5-google-terraform-modules/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/memes/f5-google-terraform-modules/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/memes/f5-google-terraform-modules/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/memes/f5-google-terraform-modules/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/memes/f5-google-terraform-modules/releases/tag/v1.0.0
