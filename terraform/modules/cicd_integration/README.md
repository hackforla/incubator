<!-- BEGIN_TF_DOCS -->
# cicd-integration

This module sets up permissions for GitHub actions to perform actions within
AWS, without the use of an IAM access key. With this module set up on a project,

Once this module is set up in a project, jobs can use the `aws-actions/configure-aws-credentials`
step with `role-to-assume` as `arn:aws:iam::035866691871:role/incubator-cicd-(project name)`

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
| [aws_iam_role.builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | HfLA project name (vrms, home-unite-us, etc) | `string` | n/a | yes |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | GitHub repository name, without any organizations or prefix - for example, `HomeUniteUs` | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | IAM role name that will be assumed by GitHub actions when running |
<!-- END_TF_DOCS -->