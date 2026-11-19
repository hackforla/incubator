<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_food_oasis_cicd"></a> [food\_oasis\_cicd](#module\_food\_oasis\_cicd) | ../../modules/cicd_integration | n/a |
| <a name="module_food_oasis_ecr_fullstack"></a> [food\_oasis\_ecr\_fullstack](#module\_food\_oasis\_ecr\_fullstack) | ../../modules/ecr | n/a |
| <a name="module_food_oasis_prod_database"></a> [food\_oasis\_prod\_database](#module\_food\_oasis\_prod\_database) | ../../modules/database | n/a |
| <a name="module_food_oasis_stage_database"></a> [food\_oasis\_stage\_database](#module\_food\_oasis\_stage\_database) | ../../modules/database | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cicd_role_arn"></a> [cicd\_role\_arn](#output\_cicd\_role\_arn) | IAM role GitHub Actions in hackforla/food-oasis assumes to push images and redeploy services |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | URL of the image repository both environments pull from |
<!-- END_TF_DOCS -->
