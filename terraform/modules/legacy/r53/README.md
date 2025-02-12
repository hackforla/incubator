<!-- BEGIN_TF_DOCS -->
# R53 

Add description.



## Resources

| Name | Type |
|------|------|
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_external_dns"></a> [alb\_external\_dns](#input\_alb\_external\_dns) | Application Load Balancer External A Record for R53 Record | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name where the application will be deployed, must already live in AWS | `string` | n/a | yes |
| <a name="input_host_names"></a> [host\_names](#input\_host\_names) | The URL where the application will be hosted, must be a subdomain of the domain\_name | `list(string)` | n/a | yes |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |


To automatically update this documentation, install terraform-docs on your local machine run the following: 
    cd <directory of README location to update>
    terraform-docs -c .terraform.docs.yml . 
<!-- END_TF_DOCS -->    