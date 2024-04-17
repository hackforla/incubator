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
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_db_instance"></a> [create\_db\_instance](#input\_create\_db\_instance) | -------------------------- Database Variables -------------------------- | `bool` | `false` | no |
| <a name="input_db_allow_major_engine_version_upgrade"></a> [db\_allow\_major\_engine\_version\_upgrade](#input\_db\_allow\_major\_engine\_version\_upgrade) | n/a | `bool` | `true` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | the database major and minor version of postgres | `string` | `"13.1"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | The instance type of the db | `string` | `"db.t3.small"` | no |
| <a name="input_db_major_version"></a> [db\_major\_version](#input\_db\_major\_version) | n/a | `string` | `"13"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The postgres database password created for the default database when the instance is booted | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | database port | `number` | `5432` | no |
| <a name="input_db_public_access"></a> [db\_public\_access](#input\_db\_public\_access) | Bool to control if instance is publicly accessible | `bool` | `false` | no |
| <a name="input_db_snapshot_migration"></a> [db\_snapshot\_migration](#input\_db\_snapshot\_migration) | Name of snapshot that will used to for new database, needs to in the same region | `string` | `""` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | The name of the default postgres user created by RDS when the instance is booted | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | a short name describing the lifecyle or stage of development that this is running for; ex: 'dev', 'qa', 'prod', 'test' | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | vpc private subnets cidrs | `list(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | vpc private subnet ids | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | vpc public subnets cidrs | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | vpc public subnet ids | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | the aws region code where this is deployed; ex: 'us-west-2', 'us-east-1', 'us-east-2' | `string` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | The overall name of the shared resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "terraform_managed": "true"<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC cidr block | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_address"></a> [db\_address](#output\_db\_address) | The aws provided URL of the database |
| <a name="output_db_identifier"></a> [db\_identifier](#output\_db\_identifier) | The AWS provided identifier |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The db adress and port for this RDS instance |
| <a name="output_db_instance_hosted_zone_id"></a> [db\_instance\_hosted\_zone\_id](#output\_db\_instance\_hosted\_zone\_id) | n/a |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | The security group id for this RDS instance |
<!-- END_TF_DOCS -->    