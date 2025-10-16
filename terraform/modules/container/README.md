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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.container_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.container](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.container_ingress_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_host_urls"></a> [additional\_host\_urls](#input\_additional\_host\_urls) | n/a | `list(string)` | `[]` | no |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | n/a | `number` | `512` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | n/a | <pre>list(object({<br/>    name = string<br/>    value = string<br/>  }))</pre> | n/a | yes |
| <a name="input_container_environment_secrets"></a> [container\_environment\_secrets](#input\_container\_environment\_secrets) | n/a | <pre>list(object({<br/>    name = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | n/a | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | n/a | `number` | `1024` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | n/a | `number` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `string` | `"/"` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | n/a | `string` | n/a | yes |
| <a name="input_listener_priority"></a> [listener\_priority](#input\_listener\_priority) | n/a | `number` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | n/a | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The overall name of the project using this infrastructure; used to group related resources by | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | n/a |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | n/a |
<!-- END_TF_DOCS -->