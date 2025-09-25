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
| [aws_autoscaling_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.bastion_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_configuration.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.bastion_all_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ssh_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_user_data_script"></a> [additional\_user\_data\_script](#input\_additional\_user\_data\_script) | n/a | `string` | `""` | no |
| <a name="input_bastion_github_file"></a> [bastion\_github\_file](#input\_bastion\_github\_file) | n/a | `map(string)` | <pre>{<br/>  "github_branch": "main",<br/>  "github_filepath": "bastion_github_users",<br/>  "github_repo_name": "Infrastructure",<br/>  "github_repo_owner": "codeforsanjose"<br/>}</pre> | no |
| <a name="input_bastion_hostname"></a> [bastion\_hostname](#input\_bastion\_hostname) | The hostname bastion, must be a subdomain of the domain\_name | `string` | n/a | yes |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | The ec2 instance type of the bastion server | `string` | `"t2.micro"` | no |
| <a name="input_cron_key_update_schedule"></a> [cron\_key\_update\_schedule](#input\_cron\_key\_update\_schedule) | The cron schedule that public keys are synced from the bastion s3 bucket to the server; default to once every hour | `string` | `"5,0,*,* * * * *"` | no |
| <a name="input_enable_hourly_cron_updates"></a> [enable\_hourly\_cron\_updates](#input\_enable\_hourly\_cron\_updates) | n/a | `string` | `"false"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key to be added as the default AMI user | `string` | `""` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | public subnet ids for where to place bastion | `list(string)` | n/a | yes |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | The overall name of the shared resources | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | -------------------------- user\_data.sh Variables -------------------------- | `string` | `"ubuntu"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br/>  "terraform_managed": "true"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_hostname"></a> [bastion\_hostname](#output\_bastion\_hostname) | The URL to access the bastion server |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | the security group id of the bastion server. Add this id to other services that run within the vpc to which you want to access externally. |
<!-- END_TF_DOCS -->    