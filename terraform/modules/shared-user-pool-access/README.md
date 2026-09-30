<!-- BEGIN_TF_DOCS -->
# shared-user-pool-access

Gives one project access to the shared Cognito user pool declared in
`terraform/cognito.tf`: the project's own app clients in that pool and, optionally,
admin rights on the pool for the project's task role. See hackforla/incubator#17.

Every client in the pool shares the pool's users, so a project that wants users of its
own should declare its own pool instead, as home-unite-us does.

## Admin rights

Set `task_role_name` to grant the role the four Cognito operations that need IAM --
`AdminGetUser`, `AdminCreateUser`, `AdminAddUserToGroup` and `AdminDeleteUser` -- on the
shared pool only. These are the same four the container module already grants on pools
tagged with the project's name; the shared pool carries no `project` tag, so this module
is the only way a project gets them there. Leave it unset for a project that only signs
users in: those APIs authorize against the end user's own credentials and need no IAM.

Note that the pool is shared, so these rights cover every project's users in it, not
just this project's.

## Client secrets

`generate_secret` cannot be read back from the API, so an imported client plans a
replacement unless it is ignored -- and replacing a client mints a new client id, which
breaks any application configured with the old one. The module therefore ignores it,
and prevents destroy so any future replacement fails loudly instead.

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
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_iam_role_policy.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clients"></a> [clients](#input\_clients) | this project's app clients in the shared pool, keyed by a short stable name. `name` is the client name Cognito shows, which is also what an application sees. | <pre>map(object({<br/>    name                                 = string<br/>    generate_secret                      = optional(bool, false)<br/>    explicit_auth_flows                  = optional(list(string), ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"])<br/>    supported_identity_providers         = optional(list(string))<br/>    callback_urls                        = optional(list(string))<br/>    allowed_oauth_flows                  = optional(list(string))<br/>    allowed_oauth_scopes                 = optional(list(string))<br/>    allowed_oauth_flows_user_pool_client = optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_task_role_name"></a> [task\_role\_name](#input\_task\_role\_name) | name of the project's task role, to grant it Cognito admin operations on the shared pool. Leave unset if the project only signs users in. | `string` | `null` | no |
| <a name="input_user_pool_arn"></a> [user\_pool\_arn](#input\_user\_pool\_arn) | ARN of the shared user pool, the resource the admin policy is scoped to | `string` | n/a | yes |
| <a name="input_user_pool_id"></a> [user\_pool\_id](#input\_user\_pool\_id) | id of the shared user pool, from aws\_cognito\_user\_pool.shared in terraform/cognito.tf | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_ids"></a> [client\_ids](#output\_client\_ids) | app client id for each entry in `clients`, keyed the same way |
<!-- END_TF_DOCS -->
