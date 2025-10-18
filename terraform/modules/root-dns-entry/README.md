<!-- BEGIN_TF_DOCS -->
# root-dns-entry

This is used to create a root DNS entry in Route 53, for example "vrms.io" or "homeunite.us"
that have no "www" or subdomain before it. The Route 53 DNS entry points to incubator's main
ingress (cloudfront or ALB). All services that require web access (frontends or API backends)
should use this.

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
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | the Route 53 hosted zone id to create the entry | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_dns_name"></a> [full\_dns\_name](#output\_full\_dns\_name) | full dns name, i.e. "qa.vrms.io" |
<!-- END_TF_DOCS -->