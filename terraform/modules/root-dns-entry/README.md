<!-- BEGIN_TF_DOCS -->
# root-dns-entry

Creates a Route 53 DNS entry that points to incubator's main ingress (cloudfront or ALB).
All services that require web access (frontends or API backends) should use this.

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
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_dns_name"></a> [full\_dns\_name](#output\_full\_dns\_name) | n/a |
<!-- END_TF_DOCS -->