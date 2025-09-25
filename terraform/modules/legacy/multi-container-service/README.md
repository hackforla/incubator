<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs-task"></a> [ecs-task](#module\_ecs-task) | ../ecs-task | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_repository.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_private_dns_namespace.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_lb.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs | `string` | n/a | yes |
| <a name="input_containers"></a> [containers](#input\_containers) | Per container service configuration. Note that subdomains are used (e.g. 'www' not 'www.example.com') | <pre>map(object({<br/>    tag               = optional(string, "latest")<br/>    desired_count     = optional(number, 1)<br/>    launch_type       = optional(string, "FARGATE")<br/>    cpu               = optional(number, 0)<br/>    memory            = optional(number, 0)<br/>    port              = optional(number, 80)<br/>    subdomains        = optional(list(string), [])<br/>    path_patterns     = optional(list(string), [])<br/>    health_check_path = optional(string, "/")<br/>    env_vars          = optional(map(any), {})<br/>    secrets           = optional(map(any), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The overall name of the project using this infrastructure; used to group related resources | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_shared_configuration"></a> [shared\_configuration](#input\_shared\_configuration) | Configuration object from shared resources | <pre>object({<br/>    alb_arn                 = string<br/>    alb_https_listener_arn  = string<br/>    cluster_id              = string<br/>    cluster_name            = string<br/>    task_execution_role_arn = string<br/>    db_identifier           = string<br/>    vpc_id                  = string<br/>    public_subnet_ids       = set(string)<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br/>  "terraform_managed": "true"<br/>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC cidr block | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The root zone\_id for the service | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->    