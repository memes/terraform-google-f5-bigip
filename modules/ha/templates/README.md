# templates

This directory contains supporting files that are used by the ha module
*after* passing through Terraform template provider. This means that ${...} and
%{...} directives are recognised and interpolated at the time Terraform is
applied.

## ConfigSync and Failover

The `do.json` template contained here is a snippet of DO, not a full declarative
onboarding JSON. This is because it will be combined with the default DO template
defined in the root `do-builder` module to create a full declaration.
