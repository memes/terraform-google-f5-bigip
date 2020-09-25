# Single NIC BIG-IP template with domain name

This example shows how to create a BIG-IP image configured to use a specific
domain, a single network interface, inside a single GCP project.

## Configuration

Create a Terraform vars file that sets the required parameters. E.g.
`terraform.tfvars`

```hcl
project_id  = "my-gcp-project-id"
region      = "us-west1"
subnet_name = "ext-west-1"
domain_name = "example.com"
```

## See also

* [Single NIC BIG-IP template](/examples/single-project-1nic/)
* [Dual NIC BIG-IP template](/examples/single-project-2nic/)
* [Shared VPC Single NIC template](/examples/sharedvpc-1nic/)
* Reference Architectures with full templates

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_key | The Secret Manager key to lookup and retrive admin user password during<br>initialization. | `string` | n/a | yes |
| image | The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps<br>release as of the publishing of this module. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-3-0-0-4-payg-good-5gbps-200318182229"` | no |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| service\_account | The service account to use for BIG-IP VMs. | `string` | n/a | yes |
| subnet | The fully-qualified subnetwork self-link to attach to the BIG-IP VM. | `string` | n/a | yes |
| zone | The compute zone which will host the BIG-IP VMs. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance\_self\_link | Self-link of the BIG-IP instance. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
