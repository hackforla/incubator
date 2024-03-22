<!-- BEGIN_TF_DOCS -->
# Groups

This module declares all of the resources necessary to create AWS IAM groups.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_access-the-data"></a> [access-the-data](#module\_access-the-data) | ../../terraform-modules/multi-container-service | n/a |
| <a name="module_database"></a> [database](#module\_database) | ../../terraform-modules/database | n/a |
| <a name="module_datastore_database"></a> [datastore\_database](#module\_datastore\_database) | ../../terraform-modules/database | n/a |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ../../terraform-modules/cheap-secrets | n/a |
| <a name="module_zone"></a> [zone](#module\_zone) | ../../terraform-modules/project-zone | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_db_instance.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_ssm_parameter.rds_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [terraform_remote_state.shared](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.21.0 |

To automatically update this documentation, install terraform-docs on your local machine run the following: 
    cd <directory of README location to update>
    terraform-docs -c .terraform.docs.yml . 
<!-- END_TF_DOCS -->    