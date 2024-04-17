<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | ~> 1.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.rds_dbowner_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.rds_dbuser_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.rds_dbviewer_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [postgresql_database.db](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_grant.user](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.viewer](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_role.db_owner](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_role.db_user](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_role.db_viewer](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [aws_db_instance.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_secretsmanager_random_password.db_password_init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_random_password) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_owner_name"></a> [owner\_name](#input\_owner\_name) | n/a | `string` | n/a | yes |
| <a name="input_shared_configuration"></a> [shared\_configuration](#input\_shared\_configuration) | Configuration object from shared resources | <pre>object({<br>    alb_arn                 = string<br>    alb_https_listener_arn  = string<br>    cluster_id              = string<br>    cluster_name            = string<br>    task_execution_role_arn = string<br>    db_identifier           = string<br>    vpc_id                  = string<br>    public_subnet_ids       = set(string)<br>  })</pre> | n/a | yes |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | n/a | `string` | `""` | no |
| <a name="input_viewer_name"></a> [viewer\_name](#input\_viewer\_name) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database"></a> [database](#output\_database) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_owner"></a> [owner](#output\_owner) | n/a |
| <a name="output_owner_password_arn"></a> [owner\_password\_arn](#output\_owner\_password\_arn) | n/a |
| <a name="output_port"></a> [port](#output\_port) | n/a |
| <a name="output_user"></a> [user](#output\_user) | n/a |
| <a name="output_user_password_arn"></a> [user\_password\_arn](#output\_user\_password\_arn) | n/a |
| <a name="output_viewer"></a> [viewer](#output\_viewer) | n/a |
| <a name="output_viewer_password_arn"></a> [viewer\_password\_arn](#output\_viewer\_password\_arn) | n/a |
<!-- END_TF_DOCS -->    