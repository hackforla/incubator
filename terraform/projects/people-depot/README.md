<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend_dev_api_secret"></a> [backend\_dev\_api\_secret](#module\_backend\_dev\_api\_secret) | ../../modules/secret | n/a |
| <a name="module_backend_dev_service"></a> [backend\_dev\_service](#module\_backend\_dev\_service) | ../../modules/container | n/a |
| <a name="module_dev_database"></a> [dev\_database](#module\_dev\_database) | ../../modules/database | n/a |
| <a name="module_dev_dns_entry"></a> [dev\_dns\_entry](#module\_dev\_dns\_entry) | ../../modules/dns-entry | n/a |
| <a name="module_people_depot_cicd"></a> [people\_depot\_cicd](#module\_people\_depot\_cicd) | ../../modules/cicd_integration | n/a |
| <a name="module_people_depot_ecr_backend"></a> [people\_depot\_ecr\_backend](#module\_people\_depot\_ecr\_backend) | ../../modules/ecr | n/a |

## Resources

| Name | Type |
|------|------|
| [random_password.cookie_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->