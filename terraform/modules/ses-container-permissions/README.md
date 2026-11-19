<!-- BEGIN_TF_DOCS -->
# ses-container-permissions

Lets one container send email through specific SES identities using its task role, so the
application needs no access keys. It creates a managed IAM policy allowing
`ses:SendEmail` and `ses:SendRawEmail` on the given identity ARNs only, and attaches it to
the task role.

SES authorizes a send against the identity of the **From** address. A container sending as
`someone@example.org` needs that address's identity, or its domain's, in `identity_arns`.
A domain identity covers every address at that domain. A send from any other address is
denied, even if the account has verified that address.

For the task role to be used, the application must create its SES client with the AWS
SDK's default credential chain. If it passes access keys explicitly, it keeps using those
keys and this policy has no effect.

The policy grants no configuration sets. An application that names one in its send
request needs that configuration set's ARN allowed as well.

Usage, with the identity created by the `ses` module:

```hcl
module "prod_ses_send" {
  source         = "../../modules/ses-container-permissions"
  name           = "food-oasis-prod-ses-send"
  task_role_name = module.prod_service.task_role_name
  identity_arns  = [module.ses_foodoasis_net.arn]
  tags           = { project = local.project_name_food_oasis }
}
```

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
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity_arns"></a> [identity\_arns](#input\_identity\_arns) | ARNs of the SES identities the container may send from, for example the `ses` module's `arn` output. Each must be the identity of a From address the application uses, or that address's domain | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | name of the IAM policy. Policy names are unique per account, so include the project and environment, for example `food-oasis-prod-ses-send` | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags for the policy, on top of the provider's default tags. Pass the project's `project` tag here | `map(string)` | `{}` | no |
| <a name="input_task_role_name"></a> [task\_role\_name](#input\_task\_role\_name) | name of the container's task role, from the `container` module's `task_role_name` output | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the send policy attached to the task role |
<!-- END_TF_DOCS -->
