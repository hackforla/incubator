<!-- BEGIN_TF_DOCS -->
# Groups

This module declares all of the resources necessary to create AWS IAM groups.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_people_depot"></a> [people\_depot](#module\_people\_depot) | ../../../terraform-modules/service | n/a |
## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.shared](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_db_password"></a> [app\_db\_password](#input\_app\_db\_password) | n/a | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | n/a | `string` | n/a | yes |
| <a name="input_root_db_password"></a> [root\_db\_password](#input\_root\_db\_password) | root database password | `string` | n/a | yes |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |


To automatically update this documentation, install terraform-docs on your local machine run the following: 
    cd <directory of README location to update>
    terraform-docs -c .terraform.docs.yml . 
<!-- END_TF_DOCS -->    