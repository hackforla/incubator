variable "identity" {
  type        = string
  description = "the SES identity to create: a domain such as `foodoasis.net`, or an email address such as `foodoasis@hackforla.org`. Anything containing `@` is treated as an email address"
}

variable "zone_id" {
  type        = string
  default     = null
  description = "the Route 53 hosted zone id to write a domain identity's DKIM records into. Leave unset when the domain's DNS is not in this account; the records are then only output, to be added by hand. Must be unset for an email address"

  validation {
    condition     = var.zone_id == null || !strcontains(var.identity, "@")
    error_message = "zone_id applies only to a domain identity. An email address has no DKIM records to write."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags for the identity, on top of the provider's default tags"
}
