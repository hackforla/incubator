<!-- BEGIN_TF_DOCS -->
# ses

Creates one SES sending identity, either a domain or a single email address. A domain
gets Easy DKIM with 2048-bit keys, so mail sent from any address at that domain is signed.
An email address can only send as itself and has no DKIM records. The identity is created
in the provider's region, which for the incubator is us-west-2. Senders must call SES in
that same region.

Zone-less mode: `zone_id` is optional. When it is set, the module writes the domain's
three DKIM CNAME records into that Route 53 zone. When it is not, the module writes no
DNS at all and the records only appear in the `dkim_records` output, for adding by hand
wherever the domain's DNS lives. Use this for a domain whose zone is not in this account
yet. SES keeps checking for the records and verifies the domain once they resolve.

Why the DKIM records use `count = 3` rather than `for_each` over the tokens: Easy DKIM
always issues exactly three tokens, but their values are unknown until the identity
exists, and `for_each` keys must be known at plan time. A fixed count plans for a new
identity in a single pass. `acm-certificate` has the same problem with its validation
records and documents it as a known limitation there.

Known limitation: whether the records are written depends on whether `zone_id` is null,
so `zone_id` must be known at plan time. A zone that already exists is fine. A zone
created in the same apply is not: its id is unknown during the plan, and the plan fails
with "Invalid count argument". Apply the zone first, or leave `zone_id` unset and add the
records later.

Custom MAIL FROM: set `mail_from_subdomain` to send with an envelope sender (Return-Path)
of `<subdomain>.<domain>` instead of SES's own `amazonses.com`. Without it, SPF passes for
amazonses.com, which does not match the From domain, and the SES console warns "MAIL FROM
record is not aligned". DMARC still passes through DKIM, which is aligned, so the subdomain
adds a second aligned path rather than fixing a delivery failure. It needs an MX record
pointing bounces back at SES's feedback endpoint and an SPF record; with `zone_id` set the
module writes both, otherwise they appear only in the `mail_from_records` output. If the MX
record is missing, SES falls back to its own domain rather than rejecting mail.

New accounts start in the SES sandbox. Until AWS approves production access for the
account and region, SES only sends to verified addresses and domains, at most 200
messages a day. Requesting production access is a manual step in the SES console and is
not done here.

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
| [aws_route53_record.dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.mail_from](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_sesv2_email_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity) | resource |
| [aws_sesv2_email_identity_mail_from_attributes.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity_mail_from_attributes) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity"></a> [identity](#input\_identity) | the SES identity to create: a domain such as `foodoasis.net`, or an email address such as `foodoasis@hackforla.org`. Anything containing `@` is treated as an email address | `string` | n/a | yes |
| <a name="input_mail_from_subdomain"></a> [mail\_from\_subdomain](#input\_mail\_from\_subdomain) | label for a custom MAIL FROM domain under a domain identity, for example `bounce` for `bounce.foodoasis.net`. Leave unset to send with SES's default `amazonses.com` envelope sender. Must be unset for an email address | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags for the identity, on top of the provider's default tags | `map(string)` | `{}` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | the Route 53 hosted zone id to write a domain identity's DKIM records into. Leave unset when the domain's DNS is not in this account; the records are then only output, to be added by hand. Must be unset for an email address | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | the identity arn, for scoping `ses:SendEmail` permissions |
| <a name="output_dkim_records"></a> [dkim\_records](#output\_dkim\_records) | the domain's three DKIM records as a list of `name`, `type` and `value`, whether or not the module wrote them. Empty for an email address |
| <a name="output_mail_from_records"></a> [mail\_from\_records](#output\_mail\_from\_records) | the custom MAIL FROM domain's MX and SPF records as a list of `name`, `type` and `value`, whether or not the module wrote them. Empty when `mail_from_subdomain` is unset |
<!-- END_TF_DOCS -->
