<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_civic-tech-index"></a> [civic-tech-index](#module\_civic-tech-index) | ./projects/civic-tech-index | n/a |
| <a name="module_civic-tech-jobs"></a> [civic-tech-jobs](#module\_civic-tech-jobs) | ./projects/civic-tech-jobs | n/a |
| <a name="module_home-unite-us"></a> [home-unite-us](#module\_home-unite-us) | ./projects/home-unite-us | n/a |
| <a name="module_people-depot"></a> [people-depot](#module\_people-depot) | ./projects/people-depot | n/a |
| <a name="module_vrms"></a> [vrms](#module\_vrms) | ./projects/vrms | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_iam_policy.incubator_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pghost"></a> [pghost](#input\_pghost) | n/a | `string` | n/a | yes |
| <a name="input_pgpassword"></a> [pgpassword](#input\_pgpassword) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->