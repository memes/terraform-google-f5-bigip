# templates

This directory contains supporting files that are used by the metadata module
*after* passing through Terraform template provider. This means that ${...} and
%{...} directives are recognised and interpolated at the time Terraform is
applied.
