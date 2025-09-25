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
| <a name="module_application_container_def"></a> [application\_container\_def](#module\_application\_container\_def) | cloudposse/ecs-container-definition/aws | 0.56.0 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../ecr | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_autoscale_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_autoscale_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener_rule.static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.subdomain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_lambda_invocation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_invocation) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_external_dns"></a> [alb\_external\_dns](#input\_alb\_external\_dns) | Application Load Balancer External A Record for R53 Record | `string` | n/a | yes |
| <a name="input_alb_https_listener_arn"></a> [alb\_https\_listener\_arn](#input\_alb\_https\_listener\_arn) | ALB https listener arn for adding rule to | `any` | n/a | yes |
| <a name="input_alb_security_group_id"></a> [alb\_security\_group\_id](#input\_alb\_security\_group\_id) | ALB Security Group ID | `string` | n/a | yes |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs | `string` | n/a | yes |
| <a name="input_aws_managed_dns"></a> [aws\_managed\_dns](#input\_aws\_managed\_dns) | Flag to either create record if domain is managed in AWS or output ALB DNS for user to manually create | `bool` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | n/a | `number` | `0` | no |
| <a name="input_container_env_vars"></a> [container\_env\_vars](#input\_container\_env\_vars) | n/a | `map(any)` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | n/a | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | n/a | `number` | `0` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | n/a | `number` | `80` | no |
| <a name="input_db_instance_endpoint"></a> [db\_instance\_endpoint](#input\_db\_instance\_endpoint) | multi-tenant database endpoint, include host and port | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | n/a | `number` | `1` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `string` | `"/"` | no |
| <a name="input_host_names"></a> [host\_names](#input\_host\_names) | n/a | `list(string)` | n/a | yes |
| <a name="input_https_listener_rules"></a> [https\_listener\_rules](#input\_https\_listener\_rules) | A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_lambda_function"></a> [lambda\_function](#input\_lambda\_function) | name of the multi-db lambda function | `string` | n/a | yes |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | How to launch the container within ECS EC2 instance or FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_path_patterns"></a> [path\_patterns](#input\_path\_patterns) | n/a | `list(string)` | `[]` | no |
| <a name="input_postgres_database"></a> [postgres\_database](#input\_postgres\_database) | non-empty map will invoke lambda function to create database and users for application | `map(string)` | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The overall name of the project using this infrastructure; used to group related resources by | `any` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public Subnets IDs | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_root_db_password"></a> [root\_db\_password](#input\_root\_db\_password) | root database password | `string` | n/a | yes |
| <a name="input_root_db_username"></a> [root\_db\_username](#input\_root\_db\_username) | root database user | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br/>  "terraform_managed": "true"<br/>}</pre> | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ECS task execution role with policy for accessing other AWS resources | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC cidr block | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_result_entry"></a> [result\_entry](#output\_result\_entry) | n/a |
<!-- END_TF_DOCS -->    