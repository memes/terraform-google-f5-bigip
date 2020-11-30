# Changelog

<!-- spell-checker: ignore markdownlint -->
<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
