<!-- BEGIN_TF_DOCS -->
# container

This module sets up a running container within ECS. This could be a backend, frontend,
or fullstack container

Some things to watch out for:
1. `listener_priority` - determines the order that load balancer rules run in when
forwarding traffic to the service. If you have a backend that runs with the path `/api/v1`,
and a frontend that just runs with `/`, make sure that the backend has a lower listener
priority than the frontend, otherwise all traffic will be sent to the frontend.

## How the target group name is built

An ELB target group name cannot exceed 32 characters. That limit is verified against
live AWS rather than assumed: `describe-target-groups` accepts a 32-character name and
returns `TargetGroupNotFound`, and rejects a 33-character one with
`ValidationError: Target group name ... cannot be longer than '32' characters`.

`name_prefix` on `aws_lb_target_group` is not an alternative -- the provider rejects it
above 6 characters, which is far too short to carry a project, an application type and
an environment.

So the module derives the name itself, from a ladder of candidates. The first one that
fits in 32 characters wins:

1. `<project>-<application_type>-<environment>-<hash>` -- the full, readable name. Every
   target group in the account uses this today except civic-tech-index's and
   civic-tech-jobs', which fall to rung 2.
2. `<initials>-<abbr>-<environment>-<hash>` -- the project reduced to the initials of its
   hyphen-separated words and the application type to two letters. These are abbreviated
   *together*, rather than trying the application type alone first, so that a name which
   overflows drops to something obviously abbreviated instead of a near-miss that still
   reads like the full name.
3. `<initials, 14 max>-<md5 of the full name, 8>-<hash>` -- at most 27 characters, so it
   always fits. This exists for a single-word project name too long for rung 2, and is
   unreachable in practice. Do not drop it because no current project reaches it: without
   it, such a name fails at apply with an AWS `ValidationError` instead of producing a
   legal, deterministic name.

Rung 3 carries two independent hashes, which looks redundant and is not. They hash
different things for different reasons: `md5` of the full name distinguishes two projects
whose initials collide, and `local.tg_suffix` changes whenever an attribute forces the
target group to be replaced.

Rungs 1 and 2 have no such collision resistance -- two projects whose initials, abbreviated
application type and environment all coincide would produce the same rung-2 name, and the
ladder does not detect that. No current pair collides. If one ever does, AWS refuses the
duplicate at apply time.

Only the target group name is abbreviated. `local.envappname` still spells the application
type out in full, because it names the ECS service, task-definition family, log group,
security group and IAM role, none of which is length-constrained.

## Giving a project an S3 bucket its container can reach

The task role already allows `s3:ListBucket`, `s3:GetObject`, `s3:PutObject` and
`s3:DeleteObject` on any bucket tagged with this project's name, so a new bucket needs no
change to this module and no change to the policy. It needs three things of its own, in
the project's own directory:

1. `aws_s3_bucket` -- the bucket itself.
2. `tags = { project = local.project_name }` on it. The value is the HfLA project name,
   never an application or repository name; see the `project` tag standard in
   DR-Machine-to-machine-IAM-scoping.
3. `aws_s3_bucket_abac` with `status = "Enabled"`. **Without this the bucket is
   unreachable**, because S3 does not evaluate tag conditions against a bucket that has
   not opted in to attribute-based access control. The failure is silent: the policy
   looks correct and the container gets AccessDenied.

Enabling ABAC also changes how that bucket's tags are managed -- `PutBucketTagging` and
`DeleteBucketTagging` stop working in favour of `TagResource` and `UntagResource`. The
provider handles this on its own, using the S3 Control tagging APIs when the caller holds
`s3:TagResource`, `s3:UntagResource` and `s3:ListTagsForResource`. `incubator-tf-apply`
and `incubator-tf-plan` both do, so there is nothing to grant; a future CI role scoped
more tightly than either would need those three actions added.

A bucket belonging to no single project -- the Terraform state buckets, the CloudTrail log
buckets -- correctly carries no `project` tag and wants no ABAC opt-in. Leaving ABAC
disabled is what keeps it out of reach of every task role.

## Cognito

The task role allows `AdminGetUser`, `AdminCreateUser`, `AdminAddUserToGroup` and
`AdminDeleteUser` on any user pool tagged with this project's name. Cognito needs no
per-resource opt-in, so tagging the pool is the whole of it.

Those four are the only Cognito operations that need IAM at all. An application's other
calls -- `SignUp`, `ConfirmSignUp`, `ResendConfirmationCode`, `InitiateAuth`,
`RespondToAuthChallenge`, `GetUser`, `GlobalSignOut`, `ForgotPassword`,
`ConfirmForgotPassword` -- are unauthenticated APIs that authorize against the end user's
own credentials. They work with no role permissions and cannot be restricted by adding
any, so an application failing on one of those has a different problem.

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
| [aws_iam_policy.execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.container](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.container_ingress_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_host_urls"></a> [additional\_host\_urls](#input\_additional\_host\_urls) | if multiple hostnames route to this container. For example, both `www.vrms.io` and `vrms.io` | `list(string)` | `[]` | no |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | defines what type of application is running, fullstack, client, backend, etc. will be used for cloudwatch logs | `string` | n/a | yes |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | CPU allocation for the container. 1024 is a full vCPU. Typically containers can run on much less | `number` | `256` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | a list of name/value pairs of environmental variables. example: `{name = 'environment', value = 'production'}` | <pre>list(object({<br/>    name = string<br/>    value = string<br/>  }))</pre> | n/a | yes |
| <a name="input_container_environment_secrets"></a> [container\_environment\_secrets](#input\_container\_environment\_secrets) | similar to `container_environment`, but values are set from secrets. Database credentails and such should use this. example: `{name = 'postgresql_password', valueFrom = (SECRET_ARN)}`. If you are using the `secret` terraform module, the ARN is an output value | <pre>list(object({<br/>    name = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The full address of the ECR image used by the container: for example `035866691871.dkr.ecr.us-west-2.amazonaws.com/civic-tech-index-backend:77845e0` | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | memory allocation in MB. 1024 is one full gig of memory | `number` | `1024` | no |
| <a name="input_container_memory_reservation"></a> [container\_memory\_reservation](#input\_container\_memory\_reservation) | Soft memory limit in MiB. ECS subtracts this from a container instance when placing the task; the container may burst above it up to `container_memory`, which stays the hard cap. EC2 launch type only. | `number` | `256` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | what port this container opens up to the outside | `number` | n/a | yes |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Ceiling on running tasks during a deploy. Defaults to 200. Values <= 100 are rejected by ECS when Availability Zone Rebalancing is enabled, which it is on this cluster. | `number` | `null` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Percent of the desired count that must stay running during a deploy. Leave null to derive from `environment`: 100 for prod, 0 everywhere else. | `number` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | path for load balancer health checks. This path should return HTTP 200 if the app is up. This path does not need to follow the prefix of `path`, it can be any path | `string` | `"/"` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | hostname for load balancer routing, ex: "www.vrms.io" | `string` | n/a | yes |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | infrastructure type, either `ec2` or `fargate`. Always use `ec2` unless you have a good reason | `string` | `"fargate"` | no |
| <a name="input_listener_priority"></a> [listener\_priority](#input\_listener\_priority) | rule priority for load balancer rules. Make sure that rules with a longer path, `/api/v1/*` have a LOWER priority (evaluated first) than shorter ones, `/*` | `number` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | path for load balancer routing, for example `/api/*` | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | HfLA project name (vrms, home-unite-us, civic-tech-index, etc). This is what the `project` tag carries, so it must be the project name from the tag standard -- never an application, environment or repository name. | `any` | n/a | yes |
| <a name="input_use_own_execution_role"></a> [use\_own\_execution\_role](#input\_use\_own\_execution\_role) | `true` (the default) runs the task under this container's own project-scoped execution role. `false` falls back to the shared `incubator-prod-ecs-task-role`, which is to be deleted once nothing uses it; this variable goes with it. See hackforla/incubator#201. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | ARN of the execution role generated for this container. It pulls the image, writes logs and reads secrets, scoped to this container's project. |
| <a name="output_execution_role_name"></a> [execution\_role\_name](#output\_execution\_role\_name) | IAM role name of the execution role generated for this container. |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | ARN of the task role that this container uses. This is the role application code runs as, and the place project-specific AWS permissions go. See [Container Permissions](https://github.com/hackforla/incubator/wiki/Container-Permissions) on the incubator wiki for what it already grants and how to add to it. |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | IAM role name of the task role that this container uses. |
<!-- END_TF_DOCS -->