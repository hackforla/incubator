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
| <a name="module_food_oasis_cicd"></a> [food\_oasis\_cicd](#module\_food\_oasis\_cicd) | ../../modules/cicd_integration | n/a |
| <a name="module_food_oasis_ecr_fullstack"></a> [food\_oasis\_ecr\_fullstack](#module\_food\_oasis\_ecr\_fullstack) | ../../modules/ecr | n/a |
| <a name="module_food_oasis_prod_database"></a> [food\_oasis\_prod\_database](#module\_food\_oasis\_prod\_database) | ../../modules/database | n/a |
| <a name="module_food_oasis_stage_database"></a> [food\_oasis\_stage\_database](#module\_food\_oasis\_stage\_database) | ../../modules/database | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.location_search](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_location_place_index.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/location_place_index) | resource |
| [aws_route53_record.acm_validation_amplify](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.acm_validation_expired](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.apex](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.dmarc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.heroku](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.sendgrid](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ses_dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cicd_role_arn"></a> [cicd\_role\_arn](#output\_cicd\_role\_arn) | IAM role GitHub Actions in hackforla/food-oasis assumes to push images and redeploy services |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | URL of the image repository both environments pull from |
| <a name="output_location_search_policy_arns"></a> [location\_search\_policy\_arns](#output\_location\_search\_policy\_arns) | IAM policy per environment allowing address search on that environment's place index, for the service's task role |
| <a name="output_place_index_names"></a> [place\_index\_names](#output\_place\_index\_names) | Amazon Location place index name per environment, for the service's PLACE\_INDEX\_NAME |
<!-- END_TF_DOCS -->
