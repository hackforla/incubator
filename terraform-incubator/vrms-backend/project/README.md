<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vrms-backend"></a> [vrms-backend](#module\_vrms-backend) | ../../../terraform-modules/service | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.shared](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | n/a | `string` | n/a | yes |
| <a name="input_database_url"></a> [database\_url](#input\_database\_url) | The url for the database which is set as an environment variable | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_gmail_client_id"></a> [gmail\_client\_id](#input\_gmail\_client\_id) | n/a | `string` | n/a | yes |
| <a name="input_gmail_refresh_token"></a> [gmail\_refresh\_token](#input\_gmail\_refresh\_token) | n/a | `string` | n/a | yes |
| <a name="input_gmail_secret_id"></a> [gmail\_secret\_id](#input\_gmail\_secret\_id) | n/a | `string` | n/a | yes |
| <a name="input_host_names"></a> [host\_names](#input\_host\_names) | list of host names for route 53 and listener rules | `list(string)` | n/a | yes |
| <a name="input_mailhog_password"></a> [mailhog\_password](#input\_mailhog\_password) | n/a | `string` | n/a | yes |
| <a name="input_root_db_password"></a> [root\_db\_password](#input\_root\_db\_password) | root database password | `string` | n/a | yes |
| <a name="input_slack_bot_token"></a> [slack\_bot\_token](#input\_slack\_bot\_token) | n/a | `string` | n/a | yes |
| <a name="input_slack_client_id"></a> [slack\_client\_id](#input\_slack\_client\_id) | n/a | `string` | n/a | yes |
| <a name="input_slack_client_secret"></a> [slack\_client\_secret](#input\_slack\_client\_secret) | n/a | `string` | n/a | yes |
| <a name="input_slack_oauth_token"></a> [slack\_oauth\_token](#input\_slack\_oauth\_token) | n/a | `string` | n/a | yes |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->    