<!-- BEGIN_TF_DOCS -->
# acm-certificate

Requests an ACM certificate, proves ownership of its domains through DNS in a Route 53
hosted zone this account holds, and attaches it to the incubator production load
balancer's HTTPS listener as an SNI certificate.

All three halves belong together. A certificate whose validation records live somewhere
else silently stops renewing when those records are edited, and a certificate that is
not attached to anything becomes ineligible for renewal and expires -- which is what
happened to the `civictechjobs.org` certificate, deleted in hackforla/incubator#185.

Two things to watch out for:

1. `validation_record_ttl` defaults to 300, but the certificates adopted in #185 were
created by hand with a mix of 60 and 300. Pass the live value when adopting an existing
certificate, otherwise the first plan rewrites a working validation record for no reason.

2. The validation records are keyed by domain, with a wildcard folded into its base
domain. Two reasons. The record names are hashes ACM only issues once the certificate
exists, so keying by them made any new certificate fail to plan with
`Invalid for_each argument`. And ACM gives `*.example.org` and `example.org` the same
record, so keying the two separately would produce two resources writing one name.
The keys used to be the record names; the callers that existed then carry `moved` blocks
for the change (hackforla/incubator#285).

Removing a certificate: the destroy order is correct without help. Terraform destroys in
reverse dependency order, so it detaches from the listener first and deletes the
certificate last, which is what ACM requires -- and the provider retries DeleteCertificate
on ResourceInUseException for 20 minutes, which covers the lag between a detach and ACM
noticing it. The hazard is a partial failure: the validation records are destroyed before
the certificate, so if the delete fails anyway -- most plausibly because the certificate is
also attached to something outside Terraform, another listener or a CloudFront
distribution -- you are left with a live certificate whose validation records are gone. It
keeps serving and silently stops renewing. If a destroy fails here, check
`aws acm describe-certificate --query Certificate.InUseBy` and fix the real attachment
rather than re-running.

Creating a new certificate plans and applies in one pass. The apply then waits until ACM
sees the validation record in public DNS. If the domain's nameservers do not point at
`zone_id` yet -- a zone being moved here from another DNS host -- ACM cannot see the
record Terraform wrote, so add the same record at the current DNS host while the apply
waits. `aws acm describe-certificate --query
'Certificate.DomainValidationOptions[].ResourceRecord'` shows it. If the wait times out,
the certificate and its records already exist, and re-running the apply resumes it.

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
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_to_load_balancer"></a> [attach\_to\_load\_balancer](#input\_attach\_to\_load\_balancer) | attach the certificate to the incubator-prod-lb HTTPS listener. Set false for a certificate the load balancer does not serve | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | the certificate's primary domain, for example `homeunite.us` or `*.vrms.io` | `string` | n/a | yes |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | additional domains the certificate covers. Do not repeat `domain_name` here -- ACM returns it in the list and the provider suppresses the difference, so listing it is redundant rather than wrong | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags for the certificate, on top of the provider's default tags | `map(string)` | `{}` | no |
| <a name="input_validation_record_ttl"></a> [validation\_record\_ttl](#input\_validation\_record\_ttl) | TTL for the validation records. Only worth setting when adopting a certificate whose live records use something else | `number` | `300` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | the Route 53 hosted zone id to write the DNS validation records into | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | the certificate arn, available only once ACM reports it ISSUED |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | the certificate's primary domain, i.e. `*.vrms.io` |
<!-- END_TF_DOCS -->
