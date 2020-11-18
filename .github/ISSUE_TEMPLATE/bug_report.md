---
name: Bug report
about: Create a report to help us improve
title: ''
labels: 'bug'
assignees: 'memes'
---
Hello and thank you for using our Terraform modules. Please complete this form
and we'll try to address the issue.

## Describe the bug

What is the problem you are seeing? Is it consistent or occasional? Please
provide as much detail as possible.

## Terraform modules used

* [ ] BIG-IP standalone
* [ ] BIG-IP HA
* [ ] BIG-IP CFE

## GCP environment

* [x] Standalone project (default)
* [ ] Shared VPC Host project
* [ ] Shared VPC Service project
* [ ] Integration with serverless (Cloud Functions, Cloud Run, App Engine, etc.)

Any other details we need to know?

## Reproducing the issue

How can we reproduce this behaviour? Which version of F5's product was used?

## Additional context

<!-- spell-checker: ignore pastebin -->
Add any other context about the problem here. Sanitised snippets of logs are
welcome, but we prefer that you upload larger files to a third-party host
(Pastebin, GCS bucket, etc.) and provide a link instead.

> **NOTE:** Include the output of the following commands:

```shell
terraform -version
terraform providers
```

*DO NOT UPLOAD OR LINK TO FILES WITH SENSITIVE INFORMATION, SERVICE ACCOUNT KEYS, ETC.*
