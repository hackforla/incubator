variable "domain_name" {
  type        = string
  description = "the certificate's primary domain, for example `homeunite.us` or `*.vrms.io`"
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "additional domains the certificate covers. Do not repeat `domain_name` here -- ACM returns it in the list and the provider suppresses the difference, so listing it is redundant rather than wrong"
}

variable "zone_id" {
  type        = string
  description = "the Route 53 hosted zone id to write the DNS validation records into"
}

variable "validation_record_ttl" {
  type        = number
  default     = 300
  description = "TTL for the validation records. Only worth setting when adopting a certificate whose live records use something else"
}

variable "attach_to_load_balancer" {
  type        = bool
  default     = true
  description = "attach the certificate to the incubator-prod-lb HTTPS listener. Set false for a certificate the load balancer does not serve"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags for the certificate, on top of the provider's default tags"
}
