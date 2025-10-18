<!-- BEGIN_TF_DOCS -->
# database

Creates a database on a shared RDS posgresql instance. The name of the
created database has the format `project-name_application-type_environment`.
For example, for the production backend database of vrms, the created
database name will be `vrms_backend_production`.

This module also creates three users:
1. viewer - read access
1. user - read/write access
1. owner - admin access

The credentials get stored as secrets (SSM parameters). The ARNs of those
parameters are output variables, listed below

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | 1.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_db_owner_password"></a> [db\_owner\_password](#module\_db\_owner\_password) | ../secret | n/a |
| <a name="module_db_owner_username"></a> [db\_owner\_username](#module\_db\_owner\_username) | ../secret | n/a |
| <a name="module_db_user_password"></a> [db\_user\_password](#module\_db\_user\_password) | ../secret | n/a |
| <a name="module_db_user_username"></a> [db\_user\_username](#module\_db\_user\_username) | ../secret | n/a |
| <a name="module_db_viewer_password"></a> [db\_viewer\_password](#module\_db\_viewer\_password) | ../secret | n/a |
| <a name="module_db_viewer_username"></a> [db\_viewer\_username](#module\_db\_viewer\_username) | ../secret | n/a |

## Resources

| Name | Type |
|------|------|
| [postgresql_database.db](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.25.0/docs/resources/database) | resource |
| [postgresql_grant.user](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.25.0/docs/resources/grant) | resource |
| [postgresql_grant.viewer](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.25.0/docs/resources/grant) | resource |
| [postgresql_role.db_owner](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.25.0/docs/resources/role) | resource |
| [postgresql_role.db_user](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.25.0/docs/resources/role) | resource |
| [postgresql_role.db_viewer](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.25.0/docs/resources/role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | frontend, backend, or fullstack | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | what environment this is for - staging, production, etc | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | HfLA project name (vrms, home-unite-us, etc) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database"></a> [database](#output\_database) | name of created postgresql database |
| <a name="output_host"></a> [host](#output\_host) | hostname URL of RDS postgresql database |
| <a name="output_owner_password"></a> [owner\_password](#output\_owner\_password) | 'owner' user password credential |
| <a name="output_owner_password_arn"></a> [owner\_password\_arn](#output\_owner\_password\_arn) | SSM parameter ARN of password for 'owner' user |
| <a name="output_owner_username"></a> [owner\_username](#output\_owner\_username) | login username of 'owner' user |
| <a name="output_port"></a> [port](#output\_port) | running port of RDS postgresql database |
| <a name="output_user_password"></a> [user\_password](#output\_user\_password) | 'user' user password credential |
| <a name="output_user_password_arn"></a> [user\_password\_arn](#output\_user\_password\_arn) | SSM parameter ARN of password for 'user' user |
| <a name="output_user_username"></a> [user\_username](#output\_user\_username) | login username of 'user' user |
| <a name="output_viewer_password"></a> [viewer\_password](#output\_viewer\_password) | 'viewer' user password credential |
| <a name="output_viewer_password_arn"></a> [viewer\_password\_arn](#output\_viewer\_password\_arn) | SSM parameter ARN of password for 'viewer' user |
| <a name="output_viewer_username"></a> [viewer\_username](#output\_viewer\_username) | login username of 'viewer' user |
<!-- END_TF_DOCS -->    