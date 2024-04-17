<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_secretsmanager_random_password.them](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_random_password) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_length"></a> [length](#input\_length) | n/a | `number` | `48` | no |
| <a name="input_scope-name"></a> [scope-name](#input\_scope-name) | n/a | `string` | n/a | yes |
| <a name="input_secret-names"></a> [secret-names](#input\_secret-names) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
<!-- END_TF_DOCS -->    