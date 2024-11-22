<!-- BEGIN_TF_DOCS -->
# ECS-Task

Add description.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_container_def"></a> [application\_container\_def](#module\_application\_container\_def) | cloudposse/ecs-container-definition/aws | 0.56.0 |
## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_autoscale_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_autoscale_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener_rule.static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_service_discovery_service.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | n/a | `number` | `0` | no |
| <a name="input_container_env_vars"></a> [container\_env\_vars](#input\_container\_env\_vars) | n/a | `map(any)` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | n/a | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | n/a | `number` | `0` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | n/a | `number` | `80` | no |
| <a name="input_container_secrets"></a> [container\_secrets](#input\_container\_secrets) | n/a | `map(any)` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | n/a | `number` | `1` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_fargate_security_group_id"></a> [fargate\_security\_group\_id](#input\_fargate\_security\_group\_id) | n/a | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `string` | n/a | yes |
| <a name="input_host_names"></a> [host\_names](#input\_host\_names) | n/a | `list(string)` | `[]` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | How to launch the container within ECS EC2 instance or FARGATE | `string` | `"FARGATE"` | no |
| <a name="input_log_group"></a> [log\_group](#input\_log\_group) | n/a | `string` | n/a | yes |
| <a name="input_path_patterns"></a> [path\_patterns](#input\_path\_patterns) | n/a | `list(string)` | `[]` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The overall name of the project using this infrastructure; used to group related resources by | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_service_discovery_dns_namespace_id"></a> [service\_discovery\_dns\_namespace\_id](#input\_service\_discovery\_dns\_namespace\_id) | n/a | `string` | n/a | yes |
| <a name="input_shared_configuration"></a> [shared\_configuration](#input\_shared\_configuration) | Configuration object from shared resources | <pre>object({<br>    alb_https_listener_arn = string<br>    cluster_id             = string<br>    cluster_name           = string<br>    vpc_id                 = string<br>    public_subnet_ids      = set(string)<br>  })</pre> | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | n/a | `string` | n/a | yes |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |


To automatically update this documentation, install terraform-docs on your local machine run the following: 
    cd <directory of README location to update>
    terraform-docs -c .terraform.docs.yml . 
<!-- END_TF_DOCS -->    