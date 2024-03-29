<!-- BEGIN_TF_DOCS -->
# Groups

This module declares all of the resources necessary to create AWS IAM groups.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_prod"></a> [prod](#module\_prod) | ../project | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gmail_client_id"></a> [gmail\_client\_id](#input\_gmail\_client\_id) | n/a | `string` | n/a | yes |
| <a name="input_gmail_refresh_token"></a> [gmail\_refresh\_token](#input\_gmail\_refresh\_token) | n/a | `string` | n/a | yes |
| <a name="input_gmail_secret_id"></a> [gmail\_secret\_id](#input\_gmail\_secret\_id) | n/a | `string` | n/a | yes |
| <a name="input_mailhog_password"></a> [mailhog\_password](#input\_mailhog\_password) | n/a | `string` | n/a | yes |
| <a name="input_slack_bot_token"></a> [slack\_bot\_token](#input\_slack\_bot\_token) | n/a | `string` | n/a | yes |
| <a name="input_slack_client_id"></a> [slack\_client\_id](#input\_slack\_client\_id) | n/a | `string` | n/a | yes |
| <a name="input_slack_client_secret"></a> [slack\_client\_secret](#input\_slack\_client\_secret) | n/a | `string` | n/a | yes |
| <a name="input_slack_oauth_token"></a> [slack\_oauth\_token](#input\_slack\_oauth\_token) | n/a | `string` | n/a | yes |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | n/a | `string` | n/a | yes |




To automatically update this documentation, install terraform-docs on your local machine run the following: 
    cd <directory of README location to update>
    terraform-docs -c .terraform.docs.yml . 
<!-- END_TF_DOCS -->    